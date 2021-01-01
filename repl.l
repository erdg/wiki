# REPL form
(de repl (Attr DX DY)
   (default DX 80  DY 25)
   (serverSentEvent "ReplSvg" '*ReplSvg)
   (form Attr
      (disable (not *Login))
      (=: repl (tmp "repl"))
      (<div> '(flex-row (style . "justify-content: flex-start;"))
         (<style> '(style . "width: 24px;")
            (<img> "wiki/img/small-logo.png") )
         (<p>
            (cons 'style
               "display: inline;
               color: #393e71;
               font-family: monospace;
               font-size: 22px;
               margin: 0px 4px;" )
            "repl" ) )
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
      (--)
      (gui 'line '(+Able +Mono +TextField)
         '(= (: home view file) (: home repl))
         (*/ DX 4 5) )
      (----)
      (<spread>
         (<style> '(placeholder . "<filename>")
            (gui 'nm '(+TextField) 20) )
         (gui '(+JS +Button) "Upload to document"
            # upload current repl svg to document
            # feels like a hack, but it works
            # BUG - need to refresh browser after button click for the new
            # svg to show up in the "Media" section of the edit form.
            '(ifn (val> (: home nm))
               (error "Please provide a name")
               (put!> (get *Top 'obj 'mup) 'bin
                  (cons
                     (prog1
                        (new! '(+Bin) 'nm (val> (: home nm)))
                        (blob! @ 'd "wiki/repl.cropped.svg") )
                     (get *Top 'obj 'mup 'bin) ) ) ) ) )
      (<ReplSvgDiv>) ) )

(de <ReplSvgDiv> ()
   (<div> '(id . ReplSvg)
      (<ReplSvg>) ) )

(de <ReplSvg> ()
   # see https://stackoverflow.com/questions/1077041/refresh-image-with-a-new-one-at-the-same-url/9943419#9943419
   # '(date)' and '(time)' to fool browser cache and update image
   (<img> (pack "http://localhost:" *WikiPort "/wiki/repl.cropped.svg#" (date) (time))) )

# send latest SVG to the browser
(de updReplSvg ()
   (serverSend *ReplSvg (<ReplSvg>)) )

# write lilypond file
(de ly Music
   (out (tmp "repl.ly")
      (lyVersion)
      (lyLayout)
      (run Music) )
   (call *Lily "-dcrop" "-dbackend=svg" "--output=wiki" (tmp "repl.ly"))
   # (call *Lily "-dcrop" "-dbackend=svg" (pack "--output=" (tmp)) (tmp "repl.ly"))
   (updReplSvg) )

(de lyEcho ()
   (in (tmp "repl.ly") (echo)) )
