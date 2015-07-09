#!/bin/tcsh
#=============================================================================
#+
# NAME:
#   make_toc.csh
#
# PURPOSE:
#   Output a markdown table of contents based on the content of the
#   README.md file.
#
# COMMENTS:
#
# INPUTS:
#
# OPTIONAL INPUTS:
#   -f filename            Input file [README.md].
#   -h --help
#
# OUTPUTS:
#   stdout
#
# EXAMPLES:
#
#   make_toc.csh -f README.md
#
# DEPENDENCIES:
#
# BUGS:
#
# REVISION HISTORY:
#   2015-07-09  started Marshall (KIPACF)
#-
#=======================================================================

unset noclobber

# Set defaults:

set help = 0
set file = README.md

# Parse command line:

while ( $#argv > 0 )
   switch ($argv[1])
   case -h:           #  print help
      set help = 1
      shift argv
      breaksw
   case --{help}:
      set help = 1
      shift argv
      breaksw
   case -f:           #  alternative input file
      shift argv
      set file = $argv[1]
      shift argv
      breaksw
   case *:
      shift argv
      breaksw
   endsw
end

#-----------------------------------------------------------------------

if ($help) then
  more `which $0`
  goto FINISH
endif

#-----------------------------------------------------------------------
# Get list of FAQ, marked with '####':

set toclist = /tmp/toclist
\rm -f $toclist

grep '####' $file > $toclist

# For each of these headings, extract the anchor name and the title text:

set nlines = `cat $toclist | wc -l`

foreach k ( `seq $nlines`)

    set line = `tail -n +$k $toclist | head -1`

    # Is an anchor defined? If not, use a blank string:
    set gotanchor = `echo "$line" | grep 'name=' | wc -l`
    if ($gotanchor) then
        set anchor = `echo "$line" | cut -d'"' -f2`
    else
        set anchor = ''
    endif

    # Pull out title text:
    if ($gotanchor) then
        set text = `echo "${line}" | sed s%'</a>'%'+'%g | cut -d'+' -f2`
    else
        set text = `echo "${line}" | sed s%'####'%'+'%g | cut -d'+' -f2`
    endif

    # Print formatted markdown line to stdout:

    echo '* ['"${text}"'](#'"${anchor}"')'

end

#-----------------------------------------------------------------------
# Clean up:

\rm -f $toclist

finish:
