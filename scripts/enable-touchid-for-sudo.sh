#!/usr/bin/env bash
#
# Enable Touch ID for sudo on macOS.
# Prefers /etc/pam.d/sudo_local over modifying /etc/pam.d/sudo.
# (c) 2025 Robb Romans
#
# Exit codes:
#   0: Touch ID already enabled (no changes), or --test and enabled, or --remove and already disabled
#   1: Error
#   2: Changes applied (not used with --dry-run)
#   3: --dry-run would make changes
#   4: --test and not enabled
#
# Options:
#   -q, --quiet     Minimal output; print only warnings/errors.
#   -v, --verbose   More output (overrides --quiet).
#   -n, --dry-run   Show what would change, but do not modify anything.
#   -t, --test      Check status only; exit 0 if enabled, 4 if not.
#   -r, --remove    Remove Touch ID authentication for sudo.
#   -h, --help      Show help.

set -euo pipefail

# -------- flags --------
QUIET=false
VERBOSE=false
DRY_RUN=false
TEST_ONLY=false
REMOVE=false

log_info()   { $QUIET || echo "$@"; }
log_verbose(){ $VERBOSE && echo "$@"; }
log_warn()   { echo "WARN: $*" >&2; }
log_error()  { echo "ERROR: $*" >&2; }

usage() {
  cat <<'EOF'
Enable Touch ID for sudo on macOS.

Exit codes:
  0: Touch ID already enabled (no changes), or --test and enabled, or --remove and already disabled
  1: Error
  2: Changes applied (not used with --dry-run)
  3: --dry-run would make changes
  4: --test and not enabled

Options:
  -q, --quiet     Minimal output; print only warnings/errors.
  -v, --verbose   More output (overrides --quiet).
  -n, --dry-run   Show what would change, but do not modify anything.
  -t, --test      Check status only; exit 0 if enabled, 4 if not.
  -r, --remove    Remove Touch ID authentication for sudo.
  -h, --help      Show help.
EOF
}

# Default: be chatty when interactive, quieter otherwise.
if [[ -t 1 ]]; then QUIET=false; else QUIET=true; fi

# -------- arg parsing --------
while [[ $# -gt 0 ]]; do
  case "$1" in
    -q|--quiet)   QUIET=true ;;
    -v|--verbose) VERBOSE=true; QUIET=false ;;
    -n|--dry-run) DRY_RUN=true ;;
    -t|--test)    TEST_ONLY=true ;;
    -r|--remove)  REMOVE=true ;;
    -h|--help)    usage; exit 0 ;;
    *) log_error "Unknown option: $1"; usage; exit 1 ;;
  esac
  shift
done

# Validate conflicting options
if $TEST_ONLY && $REMOVE; then
  log_error "Cannot use --test and --remove together"
  exit 1
fi

require_root() {
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    log_error "Run as root (e.g., with sudo)."
    exit 1
  fi
}

is_supported_macos() {
  local ver major minor patch
  ver="$(/usr/bin/sw_vers -productVersion)"
  IFS='.' read -r major minor patch <<<"${ver}.0.0"
  
  # Remove any non-digits and ensure we have valid numbers
  major=${major//[^0-9]/}
  minor=${minor//[^0-9]/}
  patch=${patch//[^0-9]/}
  
  # Default to 0 if empty
  major=${major:-0}
  minor=${minor:-0} 
  patch=${patch:-0}
  
  local n=$((10#${major}*10000 + 10#${minor}*100 + 10#${patch}))
  (( n >= 101200 ))
}

pam_module_exists() {
  # Check for both old and new naming conventions
  [[ -f "/usr/lib/pam/pam_tid.so" ]] || [[ -f "/usr/lib/pam/pam_tid.so.2" ]]
}

sudo_includes_local() {
  [[ -f "/etc/pam.d/sudo" ]] || return 1
  /usr/bin/grep -Eq '^[[:space:]]*auth[[:space:]]+include[[:space:]]+sudo_local([[:space:]]|$)' /etc/pam.d/sudo
}

touchid_pam_present() {
  local f="$1"
  [[ -f "$f" ]] || return 1
  # Check for both pam_tid.so and pam_tid.so.2
  /usr/bin/grep -Eq '^[[:space:]]*[^#].*(pam_tid\.so|pam_tid\.so\.2)' "$f"
}

is_touchid_effective() {
  # Effective if pam_tid is in sudo directly, or sudo includes sudo_local and sudo_local has pam_tid
  if touchid_pam_present "/etc/pam.d/sudo"; then
    return 0
  fi
  if sudo_includes_local && touchid_pam_present "/etc/pam.d/sudo_local"; then
    return 0
  fi
  return 1
}

backup_file() {
  local src="$1"
  local ts; ts="$(/bin/date +%Y%m%d-%H%M%S)"
  local dst; dst="$(dirname "$src")/.$(basename "$src").${ts}.bak"
  if $DRY_RUN; then
    log_verbose "Would backup $src -> $dst"
  else
    /bin/cp -p "$src" "$dst"
  fi
  echo "$dst"
}

find_latest_backup() {
  local file="$1"
  local dir pattern
  dir="$(dirname "$file")"
  pattern=".$(basename "$file").*.bak"
  
  # Find the most recent backup file
  LC_ALL=C /usr/bin/find "$dir" -name "$pattern" -type f 2>/dev/null | /usr/bin/sort -r | /usr/bin/head -n 1
}

remove_pam_tid_lines() {
  local file="$1"
  local mode owner group
  mode="$(/usr/bin/stat -f '%Lp' "$file")"
  owner="$(/usr/bin/stat -f '%Su' "$file")"
  group="$(/usr/bin/stat -f '%Sg' "$file")"

  local tmp; tmp="$(/usr/bin/mktemp "${file}.XXXXXX")"
  trap '/bin/rm -f "$tmp"' RETURN
  
  # Remove lines containing either pam_tid.so or pam_tid.so.2
  /usr/bin/grep -v '^[[:space:]]*[^#].*(pam_tid\.so|pam_tid\.so\.2)' "$file" > "$tmp"
  
  /bin/chmod "$mode" "$tmp"
  /usr/sbin/chown "$owner:$group" "$tmp"
  
  if $DRY_RUN; then
    log_verbose "Would remove pam_tid lines from $file"
    /bin/rm -f "$tmp"
    trap - RETURN
  else
    /bin/mv "$tmp" "$file"
    trap - RETURN
  fi
  return 0
}

restore_from_backup() {
  local file="$1"
  local backup; backup="$(find_latest_backup "$file")"
  
  if [[ -z "$backup" ]]; then
    log_warn "No backup found for $file"
    return 1
  fi
  
  if $DRY_RUN; then
    log_verbose "Would restore $file from $backup"
  else
    /bin/cp -p "$backup" "$file"
    log_info "Restored $file from $backup"
  fi
  return 0
}

ensure_line_in_file_first_noncomment() {
  local file="$1" ; local line="$2"
  local mode owner group
  mode="$(/usr/bin/stat -f '%Lp' "$file")"        # numeric mode like 644
  owner="$(/usr/bin/stat -f '%Su' "$file")"
  group="$(/usr/bin/stat -f '%Sg' "$file")"

  local tmp; tmp="$(/usr/bin/mktemp "${file}.XXXXXX")"
  trap '/bin/rm -f "$tmp"' RETURN
  # Insert the rule as the first non-comment line, preserving comments, atomically.
  /usr/bin/awk -v ins="$line" '
    BEGIN { inserted=0 }
    {
      if (!inserted && $0 !~ /^[[:space:]]*#/) {
        print ins
        inserted=1
      }
      print
    }
    END {
      if (!inserted) print ins
    }
  ' "$file" > "$tmp"

  /bin/chmod "$mode" "$tmp"
  /usr/sbin/chown "$owner:$group" "$tmp"
  
  # Sanity: ensure at least one non-comment pam_tid line exists (avoid pipefail in $())
  local _count
  _count="$(/usr/bin/awk '/^[[:space:]]*[^#].*pam_tid\.so/{c++} END{print c+0}' "$tmp")"
  if [[ "$_count" -ge 1 ]]; then
    if $DRY_RUN; then
      log_verbose "Would replace $file atomically"
      /bin/rm -f "$tmp"
      trap - RETURN
    else
      /bin/mv "$tmp" "$file"
      trap - RETURN
    fi
    return 0
  else
    /bin/rm -f "$tmp"
    trap - RETURN
    log_error "Failed to insert pam_tid.so into $file"
    return 1
  fi
}

append_line_if_missing() {
  local file="$1" ; local line="$2"
  if touchid_pam_present "$file"; then
    log_verbose "pam_tid already present in $file"
    return 0
  fi
  local mode owner group
  mode="$(/usr/bin/stat -f '%Lp' "$file")"
  owner="$(/usr/bin/stat -f '%Su' "$file")"
  group="$(/usr/bin/stat -f '%Sg' "$file")"

  local tmp; tmp="$(/usr/bin/mktemp "${file}.XXXXXX")"
  trap '/bin/rm -f "$tmp"' RETURN

  # Copy existing content, then append the new line
  /bin/cat "$file" > "$tmp"
  printf '%s\n' "$line" >> "$tmp"

  /bin/chmod "$mode" "$tmp"
  /usr/sbin/chown "$owner:$group" "$tmp"

  if $DRY_RUN; then
    log_verbose "Would append to $file atomically: $line"
    /bin/rm -f "$tmp"
    trap - RETURN
  else
    /bin/mv "$tmp" "$file"
    trap - RETURN
  fi
  return 0
}

write_sudo_local() {
  local f="/etc/pam.d/sudo_local"
  # Use the correct module name based on what exists
  local rule
  if [[ -f "/usr/lib/pam/pam_tid.so.2" ]]; then
    rule='auth       sufficient     pam_tid.so.2'
  else
    rule='auth       sufficient     pam_tid.so'
  fi

  if touchid_pam_present "$f"; then
    log_info "Touch ID already enabled via $f"
    return 0
  fi

  if [[ -f "$f" ]]; then
    append_line_if_missing "$f" "$rule"
    return $?
  else
    if $DRY_RUN; then
      log_verbose "Would create $f with rule"
      return 0
    else
      local tmp; tmp="$(/usr/bin/mktemp "${f}.XXXXXX")"
      trap '/bin/rm -f "$tmp"' RETURN
      (
        umask 022
        cat > "$tmp" <<'EOF'
# Local overrides for sudo PAM stack
# Added by enable-touchid-for-sudo
auth       sufficient     pam_tid.so
EOF
      )
      if ! /usr/sbin/chown root:wheel "$tmp"; then
        log_error "Failed to set ownership on $tmp"
        return 1
      fi
      if ! /bin/chmod 0644 "$tmp"; then
        log_error "Failed to set permissions on $tmp"
        return 1
      fi
      if ! /bin/mv "$tmp" "$f"; then
        log_error "Failed to move $tmp to $f"
        return 1
      fi
      trap - RETURN
      return 0
    fi
  fi
}

remove_sudo_local() {
  local f="/etc/pam.d/sudo_local"

  if [[ ! -f "$f" ]]; then
    log_verbose "$f does not exist"
    return 0
  fi

  if ! touchid_pam_present "$f"; then
    log_verbose "pam_tid not present in $f"
    return 0
  fi

  # Detect our header and measure content
  local has_our_header=false
  if /usr/bin/grep -q '^# Added by enable-touchid-for-sudo' "$f"; then
    has_our_header=true
  fi
  # Total lines (trimmed) and non-comment, non-empty lines
  local total_lines; total_lines="$(/usr/bin/awk 'END{print NR+0}' "$f")"
  local noncomment_lines; noncomment_lines="$(/usr/bin/awk '/^[[:space:]]*($|#)/{next}{c++} END{print c+0}' "$f")"

  # If it's essentially just our header + pam_tid, remove the file outright
  if $has_our_header && [[ "$noncomment_lines" -le 1 ]] && [[ "$total_lines" -le 4 ]]; then
    if $DRY_RUN; then
      log_verbose "Would remove $f (appears to be generated by this script)"
    else
      /bin/rm -f "$f"
      log_info "Removed $f"
    fi
    return 0
  fi

  # Otherwise, prune pam_tid lines; if only comments remain afterward, delete it
  remove_pam_tid_lines "$f"
  if /usr/bin/grep -q '^# Added by enable-touchid-for-sudo' "$f"; then
    local remaining_noncomment; remaining_noncomment="$(/usr/bin/awk '/^[[:space:]]*($|#)/{next}{c++} END{print c+0}' "$f")"
    if [[ "$remaining_noncomment" -eq 0 ]]; then
      if $DRY_RUN; then
        log_verbose "Would remove $f (left with only comments after cleanup)"
      else
        /bin/rm -f "$f"
        log_info "Removed $f (left with only comments after cleanup)"
      fi
      return 0
    fi
  fi

  log_info "Removed pam_tid lines from $f"
  return 0
}

edit_sudo_fallback() {
  local file="/etc/pam.d/sudo"
  # Use the correct module name based on what exists
  local rule
  if [[ -f "/usr/lib/pam/pam_tid.so.2" ]]; then
    rule='auth       sufficient     pam_tid.so.2'
  else
    rule='auth       sufficient     pam_tid.so'
  fi

  if touchid_pam_present "$file"; then
    log_info "Touch ID already enabled via $file"
    return 0
  fi

  local bak; bak="$(backup_file "$file")"
  $DRY_RUN || log_info "Backup created: $bak"
  ensure_line_in_file_first_noncomment "$file" "$rule"
  return $?
}

remove_sudo_fallback() {
  local file="/etc/pam.d/sudo"
  
  if ! touchid_pam_present "$file"; then
    log_verbose "pam_tid not present in $file"
    return 0
  fi
  
  # Try to restore from backup first
  if restore_from_backup "$file"; then
    return 0
  fi
  
  # Fallback: remove pam_tid lines manually
  log_warn "No backup available, removing pam_tid lines manually"
  local bak; bak="$(backup_file "$file")"
  $DRY_RUN || log_info "Backup created: $bak"
  remove_pam_tid_lines "$file"
  log_info "Removed pam_tid lines from $file"
  return 0
}

main() {
  require_root
  if ! is_supported_macos; then
    log_error "Requires macOS 10.12 or later."
    exit 1
  fi
  # only required when enabling
  if ! $REMOVE && ! pam_module_exists; then
    log_error "pam_tid.so not found; this Mac likely lacks Touch ID."
    exit 1
  fi
  # Fast path for --test
  if $TEST_ONLY; then
    if is_touchid_effective; then
      $QUIET || echo "Touch ID for sudo: enabled"
      exit 0
    else
      $QUIET || echo "Touch ID for sudo: NOT enabled"
      exit 4
    fi
  fi

  local before_enabled=false
  if is_touchid_effective; then before_enabled=true; fi

  # DRY RUN: decide purely from current state, do not mutate files
  if $DRY_RUN; then
    if $REMOVE; then
      if $before_enabled; then
        $QUIET || echo "Dry run: would remove Touch ID for sudo."
        exit 3
      else
        $QUIET || echo "Dry run: already disabled (no changes)."
        exit 0
      fi
    else
      if $before_enabled; then
        $QUIET || echo "Dry run: already enabled (no changes)."
        exit 0
      else
        $QUIET || echo "Dry run: would enable Touch ID for sudo."
        exit 3
      fi
    fi
  fi
  # If already enabled and not removing, exit without touching files.
  if ! $REMOVE && $before_enabled; then
    exit 0
  fi

  local success=false
  if $REMOVE; then
    # Remove Touch ID authentication
    if remove_sudo_local && remove_sudo_fallback; then
      success=true
    fi
  else
    # Add Touch ID authentication
    # First check if sudo supports sudo_local
    if sudo_includes_local; then
      # Use sudo_local since sudo will honor it
      if write_sudo_local; then
        success=true
      fi
    else
      # sudo doesn't include sudo_local, so modify sudo directly
      if edit_sudo_fallback; then
        success=true
      fi
    fi
  fi  
  
  if ! $success; then
    if $REMOVE; then
      log_error "Could not remove Touch ID for sudo."
    else
      log_error "Could not enable Touch ID for sudo."
    fi
    exit 1
  fi

  local after_enabled=false
  if is_touchid_effective; then after_enabled=true; fi

  # Determine exit code based on state changes
  if $REMOVE; then
    if ! $before_enabled; then
      # Was already disabled
      exit 0
    elif ! $after_enabled; then
      # Successfully disabled
      log_info "Touch ID for sudo disabled."
      exit 2
    else
      log_error "Unexpected state: removal reported success but TouchID still detected"
      exit 1
    fi
  else
    if $after_enabled; then
      # Successfully enabled
      log_info "Touch ID for sudo enabled."
      exit 2
    else
      log_error "Unexpected state: success reported but TouchID not detected"
      exit 1
    fi
  fi
}

main "$@"
