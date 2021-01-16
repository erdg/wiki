# dependency - https://github.com/erdg/picolisp-lily.git
#
# currently loaded at app startup
#
#  $ ./pil wiki/main.l picolisp-lily/pond.l -main -go +

# tabs for different repl syntax "skins" (standard picolisp and lilypond for
# now, macro syntax could be added)
(de metaRepl ()
   (<div> '(id . "repl")
      (<MetaReplHeader>)
      (<tab>
         ("picolisp" (pilRepl NIL 56 12))
         ("lilypond" (lilRepl NIL 56 12)) ) ) )


(de <MetaReplHeader> ()
   (<div> '(flex-row (style . "justify-content: flex-start;"))
      (<style> '(style . "width: 32px;")
         (<img> "wiki/img/small-logo.png") )
      (<p> '(id . "replHeaderText")
         "metarepl" ) ) )


# normal picolisp repl
(de pilRepl (Attr DX DY)
   (default DX 80  DY 25)
   (form Attr
      (disable (not *Login))
      (=: repl (tmp "repl"))
      (gui 'view '(+Able +FileField)
         '(<> (: file) (: home repl))
         (: repl)
         DX DY )
      (--)
      (gui '(+JS +Able +Button) '(= (: home view file) (: home repl)) "Eval"
         '(let Str (val> (: home line))
            (out (pack "+" (: home repl))
               (if (pre? "$ " Str)
                  (err NIL
                     (prinl Str)
                     (flush)
                     (in (list "sh" "-c" (cddr (chop Str)))
                        (echo) ) )
                  (err NIL
                     (prinl ": " Str)
                     (flush)
                     (catch '(NIL)
                        (in "/dev/null"
                           (up 99 @@@ "@3")
                           (up 99 @@ "@2")
                           (up 99 @ "@1")
                           (setq  "@3" "@2"  "@2" "@1"  "@1" (run (str Str) 99)) )
                        (off *Msg)
                        (println '-> "@1") ) )
                  (and *Msg (prinl @)) ) )
            (push1 '*ReplH Str)
            (clr> (: home line)) ) )
      (gui '(+JS +Button)
         '(if (= (: home view file) (: home repl)) ,"Edit" ,"Done")
         '(file> (: home view)
            (if (= (: home view file) (: home repl))
               (if (val> (: home line))
                  (setq *ReplF (push1 '*ReplH @))
                  (set> (: home line) *ReplF)
                  *ReplF )
               (clr> (: home line))
               (: home repl) ) ) )
      (gui '(+Style +Button) "closeRepl" "Close"
         '(prog (rollback) (off *ID)) )
      (gui '(+Style +Button) "themeToggle" "Light/Dark Mode"
         '(prog
            (rot *WikiCss) ) )
      (--)
      (gui 'line '(+Able +Mono +TextField)
         '(= (: home view file) (: home repl))
         (*/ DX 4 5) ) ) )


# lilypond repl
(de lilRepl (Attr DX DY)
   (default DX 80  DY 25)
   (serverSentEvent "ReplSvg" '*ReplSvg)
   (form Attr
      (disable (not *Login))
      (=: repl (tmp "repl"))
      (gui 'view '(+Able +FileField)
         '(<> (: file) (: home repl))
         (: repl)
         DX DY )
      (--)
      (gui '(+JS +Able +Button) '(= (: home view file) (: home repl)) "Eval"
         '(let Str (or (val> (: home line)) (val> (: home area)))
            (out (pack "+" (: home repl))
               (if (pre? "$ " Str)
                  (err NIL
                     (prinl Str)
                     (flush)
                     (in (list "sh" "-c" (cddr (chop Str)))
                        (echo) ) )
                  (err NIL
                     (prinl ": " Str)
                     (flush)
                     (catch '(NIL)
                        (in "/dev/null"
                           (up 99 @@@ "@3")
                           (up 99 @@ "@2")
                           (up 99 @ "@1")
                           (setq
                              "@3" "@2"
                              "@2" "@1"
                              "@1"
                                 # picolisp lilypond syntax (e.g. "{ a'4. b'8 c'2~ | c1 }" )
                                 (ifn (val> (: home lilypondSyntax))
                                    (run (str Str) 99)
                                    (ifn (val> (: home renderSvg))
                                       # debug
                                       (prog
                                          (out (tmp "lyrepl") (prin Str))
                                          (eval (lytransform (lyread (tmp "lyrepl")))) )
                                       # render svg - automatically wrap code with '(ly ...)'
                                       (prog
                                          (out (tmp "lyrepl") (prin (pack "(ly " Str " )")))
                                          (eval (lytransform (lyread (tmp "lyrepl")))) ) ) ) ) )
                        (off *Msg)
                        (println '-> "@1") ) )
                  (and *Msg (prinl @)) ) )
            (push1 '*ReplH Str)
            # (clr> (: home area))
            # (clr> (: home line))
            ) )
      (gui '(+JS +Button)
         '(if (= (: home view file) (: home repl)) ,"Edit" ,"Done")
         '(file> (: home view)
            (if (= (: home view file) (: home repl))
               (if (val> (: home line))
                  (setq *ReplF (push1 '*ReplH @))
                  (set> (: home line) *ReplF)
                  *ReplF )
               (clr> (: home line))
               (: home repl) ) ) )
      (gui '(+Style +Button) "closeRepl" "Close"
         '(prog (rollback) (off *ID)) )
      (gui '(+Style +Button) "themeToggle" "Light/Dark Mode"
         '(prog
            (rot *WikiCss) ) )
      (<div> '("flex-row right" (style . "margin: 0px 16px"))
         (<span> '(style . "font-size: smaller;") "Lilypond Syntax")
         (gui 'lilypondSyntax '(+Init +Checkbox) T)
         (<span> '(style . "font-size: smaller; margin-left: 8px;") "Render Svg")
         (gui 'renderSvg '(+Init +Checkbox) T) )
      (--)
      # (gui 'line '(+Able +Mono +TextField)
      #    '(= (: home view file) (: home repl))
      #    (*/ DX 4 5) )
      (<style> '(placeholder . "code to eval (or file to edit) goes here...")
         (gui 'line '(+Able +Mono +TextField)
            '(= (: home view file) (: home repl))
            (*/ DX 4 5) ) )
      (gui '(+JS +Tiny +Style +Button) "collapsible" "v")
      (<div> 'collapsible-content
         (<style> '(placeholder . "...or here")
            (gui 'area '(+Able +Mono +TextField)
               '(= (: home view file) (: home repl))
               (*/ DX 4 5) 6) ) )
         # (----)
      (<hr>)
      (<spread>
         (<style> '(placeholder . "<FILENAME>")
            (gui 'nm '(+TextField) 20) )
         (gui '(+Button) "Save As"
            # upload current repl.svg to document
            # feels like a hack, but it works
            '(ifn (val> (: home nm))
               (error "Please specify a name")
               (put!> (get *Top 'obj 'mup) 'bin
                  (cons
                     (prog1
                        (new! '(+Bin) 'nm (val> (: home nm)))
                        (blob! @ 'd "wiki/img/repl.cropped.svg") )
                     (get *Top 'obj 'mup 'bin) ) )
               # manually reload page so new svg appears in media chart
               # NOTE - this will have to be changed if more tabs are added to the metarepl
               (url (pack "-" (chop (get *Top 'obj)) ".html?*Menu=+0&*Tab=+2&*ID=$edit")) ) ) )
               # can't use '(url *Url)' because *Url seems to be inconsistent.
               # sometimes it is "!ping" other times it is "!ssEvt" (because lilRepl
               # creates an SSE). all this is probably because I don't *really* understand
               # how to use the PL form/gui stuff, I just hack away until the desired results
               # are achieved.
      (<ReplSvgDiv>) ) )


(de <ReplSvgDiv> ()
   (<div> '(id . ReplSvg)
      (<ReplSvg>) ) )


(de <ReplSvg> ()
   # see https://stackoverflow.com/questions/1077041/refresh-image-with-a-new-one-at-the-same-url/9943419#9943419
   # '(date)' and '(time)' to fool browser cache and update image
   (<img> (pack "http://localhost:" *WikiPort "/wiki/img/repl.cropped.svg#" (date) (time))) )


# send latest SVG to the browser
(de updReplSvg ()
   (serverSend *ReplSvg (<ReplSvg>)) )


# write lilypond file
(de ly Music
   (out (tmp "repl.ly")
      (lyVersion)
      (lyLayout)
      (run Music) )
   (call *Lily "-dcrop" "-dbackend=svg" "--output=wiki/img" (tmp "repl.ly"))
   (updReplSvg) )

(de lyEcho ()
   (in (tmp "repl.ly") (echo)) )
