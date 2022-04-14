title: Ack command
date: 2022-04-14
tags: [Linux]
categories: Linux
toc: true
---

## Name
ack - grep-like text finder 类grep的文本搜索

## SYNOPSIS
- ack [options] PATTERN [FILE...]  // 查文本  
- ack -f [options] [DIRECTORY...]  // 搜文件  

## DESCRIPTION
ack 被设计为程序员的 grep 的替代品。   

ack 在输入文件或目录中搜索与给定模式匹配的行。默认情况下， ack 打印匹配的行。如果没有给出 FILE 或 DIRECTORY，则将搜索当前目录。  

Ack 还可以列出将要搜索的文件，而无需实际搜索它们，以让您利用 ack 的文件类型过滤功能。  

## FILE SELECTION
如果没有指定文件进行搜索，无论是在命令行上还是使用 -x 选项通过管道输入，ack 都会深入到子目录中选择文件进行搜索。    
> -x    Read the list of files to search from STDIN.  

ack 对它搜索的文件很智能。它基于文件的扩展名以及在某些情况下文件的内容了解某些文件类型。可以使用 --type 选项进行这些选择。
> example: ack --type=python  

在没有文件选择的情况下，ack 搜索没有被 --ignore-dir 和 --ignore-file 选项明确排除的常规文件，这些文件要么存在于 ackrc 文件中，要么存在于命令行中。  

ack 的默认选项忽略某些文件和目录。这些包括：
- 备份文件：匹配 #*# 或以 ~ 结尾的文件。
- Coredumps：与核心匹配的文件。\d+
- 版本控制目录，如 .svn 和 .git。
    
使用 --dump 选项运行 ack 以查看设置了哪些设置。  
但是，ack 总是搜索命令行中给出的文件，不管是什么类型。如果你告诉 ack 在 coredump 中搜索，它会在 coredump 中搜索。  
    
## DIRECTORY SELECTION
Ack通过指定的起始目录的目录树递归。如果没有指定目录，则使用当前工作目录。但是，它将忽略许多版本控制系统使用的影子目录，以及Perl MakeMaker系统使用的构建目录。你可以使用——[no]ignore-dir选项从这个列表中添加或删除一个目录。该选项可以重复添加/删除忽略列表中的多个目录。    

有关未搜索的目录的完整列表，请运行 ack --dump。

## MATCHING IN A RANGE OF LINES

--range-start 和 --range-end 选项允许您指定要在每个文件中搜索的行范围。  
假设您有以下文件，称为 testfile：
```
    # This function calls print on "foo".
    sub foo {
        print 'foo';
    }
    my $print = 1;
    sub bar {
        print 'bar';
    }
    my $task = 'print';
```
调用 ack print 会给我们五个匹配项：
```
    $ ack print testfile
    # This function calls print on "foo".
        print 'foo';
    my $print = 1;
        print 'bar';
    my $task = 'print';\
```
如果我们只想在子程序中搜索 print 怎么办？我们可以指定要 ack 搜索的行的范围。范围以匹配模式 ^sub \w+ 的行开始，并以匹配 ^} 的行结束。
```
  $ ack --range-start='^sub \w+' --range-end='^}' print testfile
        print 'foo';
        print 'bar';
```
请注意， ack 搜索了两个范围的行。下面的清单显示了哪些行在范围内，哪些行不在范围内。
```
    Out # This function calls print on "foo".
    In  sub foo {
    In      print 'foo';
    In  }
    Out my $print = 1;
    In  sub bar {
    In      print 'bar';
    In  }
    Out my $task = 'print';
```
不必同时指定 --range-start 和 --range-end。 如果省略--range-start，则范围从文件中的第一行开始，即匹配--range-end的第一行。类似地，如果省略 --range-end，则范围从匹配 --range-start 的第一行到文件末尾。
例如，如果你想搜索所有 HTML 文件直到 <body> 的第一个实例，你可以这样做
```
    ack foo --range-end='<body>'
```
或者搜索 Perl 的 `__DATA__` 或 `__END__` 标记，你可以这样做
```
    ack pattern --range-end='^__(END|DATA)__'
```
范围可以在同一行开始和停止。例如:
```
    --range-start='<title>' --range-end='</title>'
```
将匹配该行作为范围的开始和结束，形成单行范围。
```
   <title>Page title</title> 
```
请注意，--range-start 和 --range-end 中的模式不受 -i、-w 和 -Q 等选项的影响，这些选项会修改被匹配的主模式的行为。  

同样，范围仅影响查找匹配项的位置。 ack 中的其他所有内容都以相同的方式工作。对范围使用 -c 选项将计算出现在这些范围内的所有匹配项。 -l 显示在某个范围内匹配的文件，-L 选项显示在某个范围内没有匹配的文件。  

用于否定匹配的 -v 选项也适用于该范围内。要在 HTML 文件的“<head>”部分中查看与“google”不匹配的行，您可以执行以下操作：
```
    ack google -v --html --range-start='<head' --range-end='</head>'
```

指定要搜索的范围不会影响匹配项的显示方式。匹配的上下文仍然是相同的，并且使用上下文选项的工作方式相同，即使上下文行超出范围，也会显示匹配的上下文行。同样， --passthru 将显示文件中的所有行，但仅显示范围内的行的匹配项。

## OPTIONS
`### --ackrc
指定要在所有其他文件之后加载的 ackrc 文件；请参阅 ["ACKRC LOCATION SEMANTICS"](#ackrc-location-semantics).
### -A NUM, --after-context=NUM
在匹配行之后打印 NUM 行。
### -B NUM, --before-context=NUM
在匹配行之前打印 NUM 行。
### --[no]break
打印来自不同文件的结果之间的中断。交互使用时默认开启。
### -C [NUM], --context[=NUM]
在匹配行周围打印 NUM 行（默认 2）上下文。您可以指定零行上下文来覆盖 ackrc 中指定的另一个上下文。
### -c, --count
抑制正常输出； 而是打印每个输入文件的匹配行数。 如果 -l 生效，它只会显示每个文件的行数匹配的行数。 如果没有 -l，某些行数可能为零。
如果结合 -h (--no-filename) ack 只输出一个总数。
### --[no]color, --[no]colour   
--color 突出显示匹配的文本。 --nocolor 抑制颜色。 除非输出被重定向，否则默认情况下这是打开的。     
在 Windows 上，此选项默认关闭，除非安装了 Win32::Console::ANSI 模块或使用了 ACK_PAGER_COLOR 环境变量。
### --color-filename=color
设置用于文件名的颜色。
### --color-match=color
设置用于匹配的颜色。
### --color-colno=color
设置用于列号的颜色。
### --color-lineno=color
设置用于行号的颜色。
### --[no]column
显示第一个匹配的列号。这对于可以将光标放在给定位置的编辑器很有帮助。
### --create-ackrc
将默认 ack 选项转储到标准输出。当您想要自定义默认值时，这很有用。
### --dump
将加载的选项列表及其来源写入标准输出。方便调试。
### --[no]env
--noenv 禁用所有环境处理。不读取 .ackrc 并忽略所有环境变量。默认情况下，ack 会考虑环境中的 .ackrc 和设置。
### --flush
--flush 立即刷新输出。默认情况下这是关闭的，除非 ack 以交互方式运行（当输出到管道或文件时）。
### -f
打印将要搜索的文件，而不实际进行任何搜索。不得指定 PATTERN，否则将被视为搜索路径。
```
--ackrc
           Specifies an ackrc file to load after all others; see "ACKRC LOCATION SEMANTICS".

       -A NUM, --after-context=NUM
           Print NUM lines of trailing context after matching lines.

       -B NUM, --before-context=NUM
           Print NUM lines of leading context before matching lines.

       --[no]break
           Print a break between results from different files. On by default when used
           interactively.

       -C [NUM], --context[=NUM]
           Print NUM lines (default 2) of context around matching lines.  You can specify zero
           lines of context to override another context specified in an ackrc.

       -c, --count
           Suppress normal output; instead print a count of matching lines for each input
           file.  If -l is in effect, it will only show the number of lines for each file that
           has lines matching.  Without -l, some line counts may be zeroes.

           If combined with -h (--no-filename) ack outputs only one total count.

       --[no]color, --[no]colour
           --color highlights the matching text.  --nocolor suppresses the color.  This is on
           by default unless the output is redirected.

           On Windows, this option is off by default unless the Win32::Console::ANSI module is
           installed or the "ACK_PAGER_COLOR" environment variable is used.

       --color-filename=color
           Sets the color to be used for filenames.

       --color-match=color
           Sets the color to be used for matches.

       --color-colno=color
           Sets the color to be used for column numbers.

       --color-lineno=color
           Sets the color to be used for line numbers.

       --[no]column
           Show the column number of the first match.  This is helpful for editors that can
           place your cursor at a given position.

       --create-ackrc
           Dumps the default ack options to standard output.  This is useful for when you want
           to customize the defaults.

       --dump
           Writes the list of options loaded and where they came from to standard output.
           Handy for debugging.

       --[no]env
           --noenv disables all environment processing. No .ackrc is read and all environment
           variables are ignored. By default, ack considers .ackrc and settings in the
           environment.

       --flush
           --flush flushes output immediately.  This is off by default unless ack is running
           interactively (when output goes to a pipe or file).

       -f  Only print the files that would be searched, without actually doing any searching.
           PATTERN must not be specified, or it will be taken as a path to search.

       --files-from=FILE
           The list of files to be searched is specified in FILE.  The list of files are
           separated by newlines.  If FILE is "-", the list is loaded from standard input.

           Note that the list of files is not filtered in any way.  If you add "--type=html"
           in addition to "--files-from", the "--type" will be ignored.

       --[no]filter
           Forces ack to act as if it were receiving input via a pipe.

       --[no]follow
           Follow or don't follow symlinks, other than whatever starting files or directories
           were specified on the command line.
           
           This is off by default.

       -g PATTERN
           Print searchable files where the relative path + filename matches PATTERN.

           Note that

               ack -g foo

           is exactly the same as

               ack -f | ack foo

           This means that just as ack will not search, for example, .jpg files, "-g" will not
           list .jpg files either.  ack is not intended to be a general-purpose file finder.

           Note also that if you have "-i" in your .ackrc that the filenames to be matched
           will be case-insensitive as well.

           This option can be combined with --color to make it easier to spot the match.

       --[no]group
           --group groups matches by file name.  This is the default when used interactively.

           --nogroup prints one result per line, like grep.  This is the default when output
           is redirected.

       -H, --with-filename
           Print the filename for each match. This is the default unless searching a single
           explicitly specified file.

       -h, --no-filename
           Suppress the prefixing of filenames on output when multiple files are searched.

       --[no]heading
           Print a filename heading above each file's results.  This is the default when used
           interactively.

       --help
           Print a short help statement.

       --help-types
           Print all known types.

       --help-colors
           Print a chart of various color combinations.

       --help-rgb-colors
           Like --help-colors but with more precise RGB colors.

       -i, --ignore-case
           Ignore case distinctions in PATTERN.  Overrides --smart-case and -I.

       -I, --no-ignore-case
           Turns on case distinctions in PATTERN.  Overrides --smart-case and -i.

       --ignore-ack-defaults
           Tells ack to completely ignore the default definitions provided with ack.  This is
           useful in combination with --create-ackrc if you really want to customize ack.

       --[no]ignore-dir=DIRNAME, --[no]ignore-directory=DIRNAME
           Ignore directory (as CVS, .svn, etc are ignored). May be used multiple times to
           ignore multiple directories. For example, mason users may wish to include
           --ignore-dir=data. The --noignore-dir option allows users to search directories
           which would normally be ignored (perhaps to research the contents of .svn/props
           directories).

           The DIRNAME must always be a simple directory name. Nested directories like foo/bar
           are NOT supported. You would need to specify --ignore-dir=foo and then no files
           from any foo directory are taken into account by ack unless given explicitly on the
           command line.

       --ignore-file=FILTER:ARGS
           Ignore files matching FILTER:ARGS.  The filters are specified identically to file
           type filters as seen in "Defining your own types".

       -k, --known-types
           Limit selected files to those with types that ack knows about.

       -l, --files-with-matches
           Only print the filenames of matching files, instead of the matching text.

       -L, --files-without-matches
           Only print the filenames of files that do NOT match.

       --match PATTERN
           Specify the PATTERN explicitly. This is helpful if you don't want to put the regex
           as your first argument, e.g. when executing multiple searches over the same set of
           files.

               # search for foo and bar in given files
               ack file1 t/file* --match foo
               ack file1 t/file* --match bar

       -m=NUM, --max-count=NUM
           Print only NUM matches out of each file.  If you want to stop ack after printing
           the first match of any kind, use the -1 options.

       --man
           Print this manual page.

       -n, --no-recurse
           No descending into subdirectories.

       -o  Show only the part of each line matching PATTERN (turns off text highlighting).
           This is exactly the same as "--output=$&".

       --output=expr
           Output the evaluation of expr for each line (turns off text highlighting). If
           PATTERN matches more than once then a line is output for each non-overlapping
           match.

           expr may contain the strings "\n", "\r" and "\t", which will be expanded to their
           corresponding characters line feed, carriage return and tab, respectively.

           expr may also contain the following Perl special variables:

           $1 through $9
               The subpattern from the corresponding set of capturing parentheses.  If your
               pattern is "(.+) and (.+)", and the string is "this and that', then $1 is
               "this" and $2 is "that".

           $_  The contents of the line in the file.

           $.  The number of the line in the file.

           $&, "$`" and "$'"
               $& is the the string matched by the pattern, "$`" is what precedes the match,
               and "$'" is what follows it.  If the pattern is "gra(ph|nd)" and the string is
               "lexicographic", then $& is "graph", "$`" is "lexico" and "$'" is "ic".

               Use of these variables in your output will slow down the pattern matching.rocess Scheduling In Linux

           $+  The match made by the last parentheses that matched in the pattern.  For
               example, if your pattern is "Version: (.+)|Revision: (.+)", then $+ will
               contain whichever set of parentheses matched.

           $f  $f is available, in "--output" only, to insert the filename.  This is a stand-
               in for the discovered $filename usage in old "ack2 --output", which is
               disallowed with "ack3" improved security.

               The intended usage is to provide the grep or compile-error syntax needed for
               editor/IDE go-to-line integration, e.g. "--output=$f:$.:$_" or
               "--output=$f\t$.\t$&"

       --pager=program, --nopager
           --pager directs ack's output through program.  This can also be specified via the
           "ACK_PAGER" and "ACK_PAGER_COLOR" environment variables.

           Using --pager does not suppress grouping and coloring like piping output on the
           command-line does.

           --nopager cancels any setting in ~/.ackrc, "ACK_PAGER" or "ACK_PAGER_COLOR".  No
           output will be sent through a pager.

       --passthru
           Prints all lines, whether or not they match the expression.  Highlighting will
           still work, though, so it can be used to highlight matches while still seeing the
           entire file, as in:

               # Watch a log file, and highlight a certain IP address.
               $ tail -f ~/access.log | ack --passthru 123.45.67.89

       --print0
           Only works in conjunction with -f, -g, -l or -c, options that only list filenames.
           The filenames are output separated with a null byte instead of the usual newline.
           This is helpful when dealing with filenames that contain whitespace, e.g.

               # Remove all files of type HTML.
               ack -f --html --print0 | xargs -0 rm -f

       -p[N], --proximate[=N]
           Groups together match lines that are within N lines of each other.  This is useful
           for visually picking out matches that appear close to other matches.

           For example, if you got these results without the "--proximate" option,

               15: First match
               18: Second match
               19: Third match
               37: Fourth match

           they would look like this with "--proximate=1"

               15: First match

               18: Second match
               19: Third match

               37: Fourth match

           and this with "--proximate=3".

               15: First match
               18: Second match
               19: Third match

               37: Fourth match

           If N is omitted, N is set to 1.

       -P  Negates the effect of the --proximate option.  Shortcut for --proximate=0.

       -Q, --literal
           Quote all metacharacters in PATTERN, it is treated as a literal.

       -r, -R, --recurse
           Recurse into sub-directories. This is the default and just here for compatibility
           with grep. You can also use it for turning --no-recurse off.

       --range-start=PATTERN, --range-end=PATTERN
           Specifies patterns that mark the start and end of a range.  See "MATCHING IN A
           RANGE OF LINES" for details.

       -s  Suppress error messages about nonexistent or unreadable files.  This is taken from
           fgrep.

       -S, --[no]smart-case, --no-smart-case
           Ignore case in the search strings if PATTERN contains no uppercase characters. This
           is similar to "smartcase" in the vim text editor.  The options overrides -i and -I.

           -S is a synonym for --smart-case.

           -i always overrides this option.

       --sort-files
           Sorts the found files lexicographically.  Use this if you want your file listings
           to be deterministic between runs of ack.

       --show-types
           Outputs the filetypes that ack associates with each file.

           Works with -f and -g options.

       -t TYPE, --type=TYPE, --TYPE
           Specify the types of files to include in the search.  TYPE is a filetype, like perl
           or xml.  --type=perl can also be specified as --perl, although this is deprecated.

           Type inclusions can be repeated and are ORed together.

           See ack --help-types for a list of valid types.

       -T TYPE, --type=noTYPE, --noTYPE
           Specifies the type of files to exclude from the search.  --type=noperl can be done
           as --noperl, although this is deprecated.


           If a file is of both type "foo" and "bar", specifying both --type=foo and
           --type=nobar will exclude the file, because an exclusion takes precedence over an
           inclusion.

       --type-add TYPE:FILTER:ARGS
           Files with the given ARGS applied to the given FILTER are recognized as being of
           (the existing) type TYPE. See also "Defining your own types".

       --type-set TYPE:FILTER:ARGS
           Files with the given ARGS applied to the given FILTER are recognized as being of
           type TYPE. This replaces an existing definition for type TYPE.  See also "Defining
           your own types".

       --type-del TYPE
           The filters associated with TYPE are removed from Ack, and are no longer considered
           for searches.

       --[no]underline
           Turns on underlining of matches, where "underlining" is printing a line of carets
           under the match.

               $ ack -u foo
               peanuts.txt
               17: Come kick the football you fool
                                 ^^^          ^^^
               623: Price per square foot
                                     ^^^

           This is useful if you're dumping the results of an ack run into a text file or
           printer that doesn't support ANSI color codes.

           The setting of underline does not affect highlighting of matches.

       -v, --invert-match
           Invert match: select non-matching lines.

       --version
           Display version and copyright information.

       -w, --word-regexp
           Force PATTERN to match only whole words.

       -x  An abbreviation for --files-from=-. The list of files to search are read from
           standard input, with one line per file.

           Note that the list of files is not filtered in any way.  If you add "--type=html"
           in addition to "-x", the "--type" will be ignored.

       -1  Stops after reporting first match of any kind.  This is different from
           --max-count=1 or -m1, where only one match per file is shown.  Also, -1 works with
           -f and -g, where -m does not.

       --thpppt
           Display the all-important Bill The Cat logo.  Note that the exact spelling of
           --thpppppt is not important.  It's checked against a regular expression.

       --bar
           Check with the admiral for traps.

       --cathy
           Chocolate, Chocolate, Chocolate!
```

## ACKRC LOCATION SEMANTICS
Ack 可以从许多来源加载其配置。 以下列表指定了 Ack 查找配置文件的来源； 找到的每一个都按此处指定的顺序加载，并且每一个都覆盖在它之前的任何源中设置的选项。 （例如，如果我在我的用户 ackrc 中设置了 --sort-files，在命令行中设置了 --nosort-files，则命令行优先）。   
- 默认值从 App::Ack::ConfigDefaults 加载。这可以使用 --ignore-ack-defaults 省略。
- Global ackrc  
  然后从全局 ackrc 加载选项。它位于类 Unix 系统上的 /etc/ackrc 中。     
  在 Windows XP 及更早版本下，全局 ackrc 位于 C:\Documents and Settings\All Users\Application Data\ackrc        
  在 Windows Vista/7 下，全局 ackrc 位于 C:\ProgramData\ackrc   
  --noenv 选项可防止加载所有 ackrc 文件。   
- User ackrc    
  然后从用户的 ackrc 加载选项。 它位于类 Unix 系统上的 $HOME/.ackrc 中。    
  在 Windows XP 和更早版本下，用户的 ackrc 位于 C:\Documents and Settings\$USER\Application Data\ackrc。    
  在 Windows Vista/7 下，用户的 ackrc 位于 C:\Users\$USER\AppData\Roaming\ackrc。   
  如果要加载不同的用户级 ackrc，可以使用 $ACKRC 环境变量指定。  
  --noenv 选项可防止加载所有 ackrc 文件。  

- Project ackrc  
  然后从项目 ackrc 加载选项。 项目ackrc是第一个名为.ackrc或_ackrc的ackrc文件，先在当前目录搜索，然后是父目录，然后是祖父目录，等等。这个可以用--noenv省略。 

- --ackrc
  --ackrc 选项可以包含在命令行中以指定可以覆盖所有其他文件的 ackrc 文件。即使存在 --noenv 也会参考它。  

- Command line
  然后从命令行加载选项。

## 附录A - ack dump
```
Defaults
========
  --ignore-directory=is:.bzr
  --ignore-directory=is:.cabal-sandbox
  --ignore-directory=is:.cdv
  --ignore-directory=is:.git
  --ignore-directory=is:.hg
  --ignore-directory=is:.metadata
  --ignore-directory=is:.pc
  --ignore-directory=is:.pytest_cache
  --ignore-directory=is:.svn
  --ignore-directory=is:CMakeFiles
  --ignore-directory=is:CVS
  --ignore-directory=is:RCS
  --ignore-directory=is:SCCS
  --ignore-directory=is:_MTN
  --ignore-directory=is:__MACOSX
  --ignore-directory=is:__pycache__
  --ignore-directory=is:_build
  --ignore-directory=is:_darcs
  --ignore-directory=is:_sgbak
  --ignore-directory=is:autom4te.cache
  --ignore-directory=is:blib
  --ignore-directory=is:cover_db
  --ignore-directory=is:node_modules
  --ignore-directory=is:~.dep
  --ignore-directory=is:~.dot
  --ignore-directory=is:~.nib
  --ignore-directory=is:~.plst
  --ignore-file=ext:bak
  --ignore-file=ext:gif,jpg,jpeg,png
  --ignore-file=ext:gz,tar,tgz,zip
  --ignore-file=ext:mo
  --ignore-file=ext:pdf
  --ignore-file=ext:pyc,pyd,pyo
  --ignore-file=ext:so
  --ignore-file=is:.DS_Store
  --ignore-file=is:.git
  --ignore-file=match:/[.-]min[.]js$/
  --ignore-file=match:/[.]css[.]map$/
  --ignore-file=match:/[.]css[.]min$/
  --ignore-file=match:/[.]js[.]map$/
  --ignore-file=match:/[.]js[.]min$/
  --ignore-file=match:/[.]min[.]css$/
  --ignore-file=match:/[._].*[.]swp$/
  --ignore-file=match:/^#.+#$/
  --ignore-file=match:/core[.]\d+$/
  --ignore-file=match:/~$/
  --type-add=actionscript:ext:as,mxml
  --type-add=ada:ext:ada,adb,ads
  --type-add=asm:ext:asm,s
  --type-add=asp:ext:asp
  --type-add=aspx:ext:master,ascx,asmx,aspx,svc
  --type-add=batch:ext:bat,cmd
  --type-add=bazel:ext:bazelrc
  --type-add=bazel:ext:bzl
  --type-add=bazel:is:BUILD
  --type-add=bazel:is:WORKSPACE
  --type-add=cc:ext:c,h,xs
  --type-add=cfmx:ext:cfc,cfm,cfml
  --type-add=clojure:ext:clj,cljs,edn,cljc
  --type-add=cmake:ext:cmake
  --type-add=cmake:is:CMakeLists.txt
  --type-add=coffeescript:ext:coffee
  --type-add=cpp:ext:cpp,cc,cxx,m,hpp,hh,h,hxx
  --type-add=csharp:ext:cs
  --type-add=css:ext:css
  --type-add=dart:ext:dart
  --type-add=delphi:ext:pas,int,dfm,nfm,dof,dpk,dproj,groupproj,bdsgroup,bdsproj
  --type-add=elisp:ext:el
  --type-add=elixir:ext:ex,exs
  --type-add=elm:ext:elm
  --type-add=erlang:ext:erl,hrl
  --type-add=fortran:ext:f,f77,f90,f95,f03,for,ftn,fpp
  --type-add=go:ext:go
  --type-add=groovy:ext:groovy,gtmpl,gpp,grunit,gradle
  --type-add=gsp:ext:gsp
  --type-add=haskell:ext:hs,lhs
  --type-add=hh:ext:h
  --type-add=hpp:ext:hpp,hh,h,hxx
  --type-add=html:ext:htm,html,xhtml
  --type-add=jade:ext:jade
  --type-add=java:ext:java,properties
  --type-add=js:ext:js
  --type-add=json:ext:json
  --type-add=jsp:ext:jsp,jspx,jspf,jhtm,jhtml
  --type-add=kotlin:ext:kt,kts
  --type-add=less:ext:less
  --type-add=lisp:ext:lisp,lsp
  --type-add=lua:ext:lua
  --type-add=lua:firstlinematch:/^#!.*\blua(jit)?/
  --type-add=make:ext:mak
  --type-add=make:ext:mk
  --type-add=make:is:GNUmakefile
  --type-add=make:is:Makefile
  --type-add=make:is:Makefile.Debug
  --type-add=make:is:Makefile.Release
  --type-add=make:is:makefile
  --type-add=markdown:ext:md,markdown
  --type-add=matlab:ext:m
  --type-add=objc:ext:m,h
  --type-add=objcpp:ext:mm,h
  --type-add=ocaml:ext:ml,mli,mll,mly
  --type-add=perl:ext:pl,pm,pod,t,psgi
  --type-add=perl:firstlinematch:/^#!.*\bperl/
  --type-add=perltest:ext:t
  --type-add=php:ext:php,phpt,php3,php4,php5,phtml
  --type-add=php:firstlinematch:/^#!.*\bphp/
  --type-add=plone:ext:pt,cpt,metadata,cpy,py
  --type-add=pod:ext:pod
  --type-add=purescript:ext:purs
  --type-add=python:ext:py
  --type-add=python:firstlinematch:/^#!.*\bpython/
  --type-add=rake:is:Rakefile
  --type-add=rr:ext:R
  --type-add=rst:ext:rst
  --type-add=ruby:ext:rb,rhtml,rjs,rxml,erb,rake,spec
  --type-add=ruby:firstlinematch:/^#!.*\bruby/
  --type-add=ruby:is:Rakefile
  --type-add=rust:ext:rs
  --type-add=sass:ext:sass,scss
  --type-add=scala:ext:scala
  --type-add=scheme:ext:scm,ss
  --type-add=shell:ext:sh,bash,csh,tcsh,ksh,zsh,fish
  --type-add=shell:firstlinematch:/^#!.*\b(?:ba|t?c|k|z|fi)?sh\b/
  --type-add=smalltalk:ext:st
  --type-add=smarty:ext:tpl
  --type-add=sql:ext:sql,ctl
  --type-add=stylus:ext:styl
  --type-add=svg:ext:svg
  --type-add=swift:ext:swift
  --type-add=swift:firstlinematch:/^#!.*\bswift/
  --type-add=tcl:ext:tcl,itcl,itk
  --type-add=tex:ext:tex,cls,sty
  --type-add=toml:ext:toml
  --type-add=ts:ext:ts,tsx
  --type-add=ttml:ext:tt,tt2,ttml
  --type-add=vb:ext:bas,cls,frm,ctl,vb,resx
  --type-add=verilog:ext:v,vh,sv
  --type-add=vhdl:ext:vhd,vhdl
  --type-add=vim:ext:vim
  --type-add=xml:ext:xml,dtd,xsd,xsl,xslt,ent,wsdl
  --type-add=xml:firstlinematch:/<[?]xml/
  --type-add=yaml:ext:yaml,yml
```
