awk '
  BEGIN {
    delimiter_found = 0
    in_post_delim = 0
    line_count = 0
  }

  /^-- $/ && !delimiter_found {
    delimiter_found = 1
    in_post_delim = 1
    delimiter_line = NR
    # Add backslash to the delimiter line itself
    print $0 "\\"
    next
  }

  !delimiter_found {
    print
    next
  }

  in_post_delim {
    # Store lines in array for processing
    lines[++line_count] = $0
  }

  END {
    if (!delimiter_found) { exit }

    for (i = 1; i <= line_count; i++) {
      current = lines[i]
      next_line = (i < line_count) ? lines[i + 1] : ""

      # Check if we should add backslash
      if (current != "" && next_line != "" && i < line_count) {
        print current " \\"
      } else {
        print current
      }
    }
  }
'
