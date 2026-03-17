#!/bin/bash
# Pass if found.txt exists and contains exactly auth.log, worker.log, mailer.log
# (the three files that have ERROR lines) — order doesn't matter

if [ ! -f "/home/user/found.txt" ]; then
  echo "found.txt does not exist. Write the names of files containing ERROR to found.txt"
  exit 1
fi

EXPECTED=("auth.log" "worker.log" "mailer.log")
MISSING=()
EXTRA=()

for f in "${EXPECTED[@]}"; do
  if ! grep -qF "$f" /home/user/found.txt; then
    MISSING+=("$f")
  fi
done

# Check for any extra wrong files listed
while IFS= read -r line; do
  line=$(echo "$line" | tr -d '[:space:]')
  [ -z "$line" ] && continue
  FOUND=false
  for f in "${EXPECTED[@]}"; do
    [ "$line" = "$f" ] && FOUND=true
  done
  $FOUND || EXTRA+=("$line")
done < /home/user/found.txt

if [ ${#MISSING[@]} -eq 0 ] && [ ${#EXTRA[@]} -eq 0 ]; then
  echo "Correct! found.txt lists exactly the 3 files containing ERROR."
  exit 0
fi
[ ${#MISSING[@]} -gt 0 ] && echo "Missing from found.txt: ${MISSING[*]}"
[ ${#EXTRA[@]} -gt 0 ]   && echo "Shouldn't be in found.txt: ${EXTRA[*]}"
exit 1