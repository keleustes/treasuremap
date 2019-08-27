/---/ {
   if (NR != 1) {
     print "  target_state: uninitialized"
   }
}

{
   print $0;
}

END {
  print "  target_state: uninitialized"
}
