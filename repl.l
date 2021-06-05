# dependency - https://github.com/erdg/picolisp-lily.git
#
# currently loaded at app startup
#
#  $ ./pil wiki/main.l picolisp-lily/pond.l -main -go +

# tabs for different repl syntax "skins" (standard picolisp and lilypond for
# now, "macro" syntax could be added)
(de metaRepl ()
   (<div> (metaReplStyles)
      (<MetaReplHeader>)
      (<MetaReplTabs>) ) )

(de metaReplStyles ()
   (list
      '(id . "repl")
      (if *FullscreenRepl
         (cons 'style
            "position: fixed;
            margin: 0 auto;
            top: 0px;
            left: 0px;
            width: 100%;
            height: 100%;
            overflow: auto;
            border-radius: 0px;" ) ) ) )

(de <MetaReplHeader> ()
   (<div> '(flex-row (style . "justify-content: flex-start;"))
      (<style> '(style . "width: 32px;")
         (<img> "wiki/img/small-logo.png") )
   (<p> '(id . "replHeaderText")
         "metaRepl" )
   # tab buttons
   (<div> 'tabs
      (<htmlbutton> '("tabBtn"     (id . "picolispBtn") (onclick . "openTab('picolisp')")) "picolisp")
      (<htmlbutton> '("tabBtn top" (id . "lilypondBtn") (onclick . "openTab('lilypond')")) "lilypond")
      (<htmlbutton> '("tabBtn"     (id . "optionsBtn")  (onclick . "openTab('options')"))  "options") ) ) )

(de <MetaReplTabs> ()
   # (<div> 'tabs
   #    (<htmlbutton> '("tabBtn"     (id . "picolispBtn") (onclick . "openTab('picolisp')")) "picolisp")
   #    (<htmlbutton> '("tabBtn top" (id . "lilypondBtn") (onclick . "openTab('lilypond')")) "lilypond")
   #    (<htmlbutton> '("tabBtn"     (id . "optionsBtn")  (onclick . "openTab('options')"))  "options") )
   # tab views
   (<div> '("tabView" (id . "picolisp") (style . "display: none;"))
      (pilRepl (if *FullscreenRepl 'PilReplFullscreen) 56 20) )
   (<div> '("tabView" (id . "lilypond"))
      (if *FullscreenRepl
         (lilReplFullscreen NIL 56 20)
         (lilRepl NIL 56 10) ) )
   (<div> '("tabView" (id . "options") (style . "display: none;"))
      (form NIL
         (<div> 'flex-col
            (<style> '(style . "margin: 4px 8px")
               (gui '(+Style +Button) "themeToggle" "Light/Dark Mode"
                  '(prog
                     (rot *WikiCss)
                     (url (pack (ext.html (get *Top 'obj)) "?*Menu=+0&*Tab=+2&*ID=$edit")) ) )
               (gui '(+Button) "Toggle Document Code Sections"
                  '(prog
                     (onOff *DisplayDocumentCode)
                     (url (pack (ext.html (get *Top 'obj)) "?*Menu=+0&*Tab=+2&*ID=$edit")) ) ) ) ) ) ) )

(de tabsJS ()
   (<javascript>
      "function openTab(tabName) {
         var i;
         var tabs = document.getElementsByClassName('tabView');
         for (i = 0; i < tabs.length; i++) {
            tabs[i].style.display = 'none';
         }
         var btns = document.getElementsByClassName('tabBtn');
         for (i = 0; i < btns.length; i++) {
            btns[i].classList.remove('top');
         }
         document.getElementById(tabName).style.display = 'block';
         document.getElementById(tabName + 'Btn').classList.add('top');
      }" ) )

# normal picolisp repl
(de pilRepl (Attr DX DY)
   (default DX 80  DY 25)
   (form Attr
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
      (<style> '(style . "margin-top: 8px")
         (gui 'line '(+Able +Mono +TextField)
            '(= (: home view file) (: home repl))
            (*/ DX 4 5) ) )
      # (--)

      # resize / close buttons (top right)
      (<style> '(style . "position: absolute; top: 12px; right: 34px; padding: 2px 1px;")
         (if *FullscreenRepl
            (gui '(+Style +Tip +Button) "mono" "Exit Fullscreen" "[-]"
               '(prog
                  (off *FullscreenRepl)
                  (url (pack (ext.html (get *Top 'obj)) "?*Menu=+0&*Tab=+2&*ID=$edit")) ) )
            (gui '(+Style +Tip +Button) "mono" "Fullscreen" "[+]"
               '(prog
                  (on *FullscreenRepl)
                  (url (pack (ext.html (get *Top 'obj)) "?*Menu=+0&*Tab=+2&*ID=$edit")) ) ) ) )
      (<style> '(style . "position: absolute; top: 12px; right: 2px;")
         (gui '(+Style +Button) "closeRepl right" "x"
            '(prog (rollback) (off *ID)) ) ) ) )


# lilypond repl
(de lilRepl (Attr DX DY)
   (default DX 80  DY 25)
   (serverSentEvent "ReplSvg" '*ReplSvg)
   (form Attr

      (=: repl (tmp "repl"))
      (=: lyrepl (tmp "lyrepl"))

      # Run line
      # (<hr>)
      (<div> '(flex-row (style . "position: relative;"))
         (gui '(+JS +Style +Button) "runButton" "Run"
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
                                             (eval
                                                # (lytransform (lyread (tmp "lyrepl")))
                                                (progLilypond) ) )
                                          # render svg - automatically wrap code with '(ly ...)'
                                          (prog
                                             (out (: home lyrepl) (prin Str))
                                             (ly
                                                (prog
                                                   (when (val> (: home renderFont))
                                                      (list (any (pack 'ly @ 'Font))) )
                                                   (eval
                                                      (progLilypond) ) ) )
                                                      # (lytransform
                                                      #    # implicit 'prog'
                                                      #    (append
                                                      #       (cons
                                                      #          (char 40)
                                                      #          'prog
                                                      #          (lyread (: home lyrepl)) )
                                                      #       (list (char 41)) ) )
                                             # (out (tmp "lyrepl")
                                             #    (prin
                                             #       (pack
                                             #          "(ly "
                                             #             "(prog "
                                             #                "("
                                             #                   (when (val> (: home renderFont))
                                             #                     (pack 'ly @ 'Font))
                                             #                ")"
                                             #                Str ") )" ) ) )
                                             # (eval (lytransform (lyread (tmp "lyrepl"))))
                                             ) ) ) ) )
                           (off *Msg)
                           (println '-> "@1") ) )
                     (and *Msg (prinl @)) ) )
               (push1 '*ReplH Str) ) )

#          (<style> '("clipInputArea tiny submit"
#                      # (id . "copyBtn")
#                      (style . "position: absolute; right: 2%;"))
#             (gui '(+JS +Button) "copy") )

         (<style> '((style . "flex-grow: 1; margin: 8px 8px;") (placeholder . "code here") )
            (gui 'line '(+Mono +TextField)
               (*/ DX 4 5) ) ) )

      (<RunLineOptions>)
      # # Run line options - render, etc...
      # (<div> '("flex-row mono" (style . "margin: 0px 16px; font-size: smaller; justify-content: flex-end;"))
      #    # this is rarely used
      #    (<div> '(flex-row (style . "margin: 0px 8px; display: none;"))
      #       (<span> NIL "Lilypond Syntax")
      #       (gui 'lilypondSyntax '(+Init +Checkbox) T) )
      #    (<div> '(flex-row (style . "margin: 0px 8px"))
      #       (<span> NIL "render")
      #       (gui 'renderSvg '(+Init +Checkbox) T) )
      #    (<div> '(flex-row (style . "margin: 8px 8px"))
      #       (gui 'renderFont '(+TextField)
      #          '("Jazz" "Improviso" "Beethoven" "Haydn")
      #          "style" ) ) )

      # resize / close buttons (absolute positioned top right)
      (<style> '(style . "position: absolute; top: 12px; right: 34px; padding: 2px 1px;")
         (gui '(+Style +Tip +Button) "mono" "Fullscreen" "[+]"
            '(prog
               (on *FullscreenRepl)
               (url (pack (ext.html (get *Top 'obj)) "?*Menu=+0&*Tab=+2&*ID=$edit")) ) ) )
      (<style> '(style . "position: absolute; top: 12px; right: 2px;")
         (gui '(+Style +Button) "closeRepl right" "x"
            '(prog (rollback) (off *ID)) ) )

      # collapsible input area
      (<p> '(collapseBtnLabel (style . "margin: 4px;")) "or here")
      (<style> '((style . "padding: 1px 3px; border-radius: 3px; margin-bottom: 8px"))
         (gui '(+JS +Tiny +Style +Button) "collapsible tiny" "v"
            '(set> (: home line) NIL) ) )
      (<div> 'collapsible-content
         (<div> '(style . "position: relative;")
            (<style> '("clipInputAreaRaw tiny submit" (style . "position: absolute; top: 6%; right: 4%;"))
               (gui '(+JS +Button) "copy") )
            (<style> '("clipInputArea tiny submit" (style . "position: absolute; top: 16%; right: 4%;"))
               (gui '(+JS +Button) ":{ ... }") )
            # (<style> '("lilInputArea" (placeholder . " ..or here"))
            #    (gui 'area '(+Mono +TextField)
            #       (*/ DX 4 5) 14 ) )
            (<style> '("lilInputArea" (placeholder . "more space for code!"))
               (gui 'area '(+Mono +FileField)
                  (: lyrepl)
                  (*/ DX 4 5) 10 ) ) ) )

      # (<hr>)

#       # collapsible output area
#       (<p> 'collapseBtnLabel "output")
#       (<style> '((style . "padding: 1px 3px; border-radius: 3px"))
#          (gui '(+JS +Tiny +Style +Button) "collapsible tiny" "v") )
#       (<div> 'collapsible-content
#          (gui 'view '(+Able +FileField)
#             '(<> (: file) (: home repl))
#             (: repl)
#             DX DY ) )

#       (<hr>)

#       # music svg section
#       (<spread>
#          (<style> '(placeholder . "<FILENAME>")
#             (gui 'nm '(+TextField) 20) )
#          (gui '(+Button) "Save As"
#             # upload current repl.svg to document
#             # feels like a hack, but it works
#             '(ifn (val> (: home nm))
#                (error "Please specify a name")
#                (put!> (get *Top 'obj 'mup) 'bin
#                   (cons
#                      (prog1
#                         (new! '(+Bin) 'nm (val> (: home nm)))
#                         (blob! @ 'd "wiki/img/repl.cropped.svg") )
#                      (get *Top 'obj 'mup 'bin) ) )
#                # reload page so new svg appears in media chart
#                (url (pack (ext.html (get *Top 'obj)) "?*Menu=+0&*Tab=+2&*ID=$edit")) ) ) )
#             # can't use '(url *Url)' because *Url seems to be inconsistent.
#             # sometimes it is "!ping" other times it is "!ssEvt" (because lilRepl
#             # creates an SSE). all this is probably because I don't *really* understand
#             # how to use the PL form/gui stuff, I just hack away until the desired results
#             # are achieved.
#       (<ReplSvgDiv>) ) )

   # using 'stabs.js'
   (<div> '(tabcontainer (style . "margin-top: 24px"))
      (<div> '(flex-row (style . "margin-bottom: 8px; justify-content: flex-start;"))
         # buttons
         (<htmlbutton>
            '("tab active"
               (id . "tab1")
               (tab-index . 0)
               (role . "tab")
               (aria-controls . "tabpane1")
               (aria-selected . "true")
            )
            "music" )
         (<htmlbutton>
            '("tab"
               (id . "tab2")
               (tab-index . 0)
               (role . "tab")
               (aria-controls . "tabpane2")
               (aria-selected . "false")
            )
            "debug" )
         )
      # (<style> '(style . "margin: 16px 0px")
      #    (<hr>) )
      # views
      (<div> NIL
         (<div>
            '("tabpane active"
               (id . "tabpane1")
               (role . "tabpanel")
               (aria-labelledby . "tab1")
               (aria-hidden . "false")
            )
            (<spread>
               (<style> '(placeholder . "<filename>")
                  (gui 'nm '(+Style +TextField) "mono" 20) )
               (gui '(+Style +Button) "saveAsButton" "Save As"
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
                     # reload page so new svg appears in media chart
                     (url (pack (ext.html (get *Top 'obj)) "?*Menu=+0&*Tab=+2&*ID=$edit")) ) ) )
                  # can't use '(url *Url)' because *Url seems to be inconsistent.
                  # sometimes it is "!ping" other times it is "!ssEvt" (because lilRepl
                  # creates an SSE). all this is probably because I don't *really* understand
                  # how to use the PL form/gui stuff, I just hack away until the desired results
                  # are achieved.
            (<ReplSvgDiv>) )
         (<div>
            '("tabpane"
               (id . "tabpane2")
               (role . "tabpanel")
               (aria-labelledby . "tab2")
               (aria-hidden . "true")
               (hidden . "true")
               )
            (gui 'view '(+Style +Able +FileField)
               "debugView"
               '(<> (: file) (: home repl))
               (: repl)
               DX DY ) ) ) ) ) )


   # # this is the idea, but PL <tab> makes me mad
   # (<tab>
   #    ("music"
   #       # music svg section
   #       (<spread>
   #          (<style> '(placeholder . "<FILENAME>")
   #             (gui 'nm '(+TextField) 20) )
   #          (gui '(+Button) "Save As"
   #             # upload current repl.svg to document
   #             # feels like a hack, but it works
   #             '(ifn (val> (: home nm))
   #                (error "Please specify a name")
   #                (put!> (get *Top 'obj 'mup) 'bin
   #                   (cons
   #                      (prog1
   #                         (new! '(+Bin) 'nm (val> (: home nm)))
   #                         (blob! @ 'd "wiki/img/repl.cropped.svg") )
   #                      (get *Top 'obj 'mup 'bin) ) )
   #                # reload page so new svg appears in media chart
   #                (url (pack (ext.html (get *Top 'obj)) "?*Menu=+0&*Tab=+2&*ID=$edit")) ) ) )
   #             # can't use '(url *Url)' because *Url seems to be inconsistent.
   #             # sometimes it is "!ping" other times it is "!ssEvt" (because lilRepl
   #             # creates an SSE). all this is probably because I don't *really* understand
   #             # how to use the PL form/gui stuff, I just hack away until the desired results
   #             # are achieved.
   #       (<ReplSvgDiv>) )
   #    ("debug"
   #       (gui 'view '(+Able +FileField)
   #          '(<> (: file) (: home repl))
   #          (: repl)
   #          DX DY ) ) ) ) )

# wrap lilypond input with implicit 'prog'
(de progLilypond ()
   (lytransform
      (append
         (cons
            (char 40)
            'prog
            (lyread (: home lyrepl)) )
         (list (char 41)) ) ) )

(de <RunLineOptions> ()
   # Run line options - render, etc...
   (<div> '("flex-row mono" (style . "margin: 8px 16px; font-size: smaller; justify-content: flex-end;"))
      # this is rarely used
      (<div> '(flex-row (style . "margin: 0px 8px; display: none;"))
         (<span> NIL "Lilypond Syntax")
         (gui 'lilypondSyntax '(+Init +Checkbox) T) )
      (<div> '(flex-row (style . "margin: 0px 8px"))
         (<span> NIL "render")
         (gui 'renderSvg '(+Init +Checkbox) T) )
      (<div> '(flex-row (style . "margin: 0px 8px"))
         (gui 'renderFont '(+TextField)
            '("Jazz" "Improviso" "Beethoven" "Haydn")
            "style" ) ) ) )


# fullscreen lilypond repl
(de lilReplFullscreen (Attr DX DY)
   (default DX 80  DY 25)
   (serverSentEvent "ReplSvgFullscreen" '*ReplSvgFullscreen)
   (form Attr

      (=: repl (tmp "repl"))
      (=: lyrepl (tmp "lyrepl"))

      (<div> '(flex-row (style . "align-items: flex-start; justify-content: flex-start;"))

         (<div> 'flex-col

#             (gui 'view '(+Style +Able +FileField)
#                "ReplOutputFullscreen"
#                '(<> (: file) (: home repl))
#                (: repl)
#                DX DY )

            (<div> '(flex-row (style . "position: relative;"))

               # Run Button
               (gui '(+JS +Style +Button) "runButton" "Run"
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
                                                   (out (: home lyrepl) (prin Str))
                                                   (eval (progLilypond)) )
                                                # render svg - automatically wrap code with '(ly ...)'
                                                (prog
                                                   # (out (: home lyrepl)
                                                   #    (prin
                                                   #       (pack
                                                   #          "(ly "
                                                   #             "(prog "
                                                   #                (when (val> (: home renderFont))
                                                   #                  (pack "(" 'ly @ 'Font ")") )
                                                   #                Str ") )" ) ) )
                                                   # (eval (lytransform (lyread (: home lyrepl))))
                                                   (out (: home lyrepl) (prin Str))
                                                   (ly
                                                      (prog
                                                         (when (val> (: home renderFont))
                                                            (list (any (pack 'ly @ 'Font))) )
                                                         (eval
                                                            (progLilypond) ) ) ) ) ) ) ) )
                                 (off *Msg)
                                 (println '-> "@1") ) )
                           (and *Msg (prinl @)) ) )
                     (push1 '*ReplH Str) ) )

               # (<style> '("clipInputArea tiny submit"
               #             # (id . "copyBtn")
               #             (style . "position: absolute; top: 18%; right: 3%;"))
               #    (gui '(+JS +Button) "copy") )

               # Run line
               (<style> '("ReplLineFullscreen" (style . "flex-grow: 1; margin: 8px 8px;") (placeholder . "code here"))
                  (gui 'line '(+Mono +TextField)
                     (*/ DX 4 5) ) )

               (<RunLineOptions>) )

            (<div> '(style . "position: relative;")
               (<style> '("clipInputAreaRaw tiny submit" (style . "position: absolute; top: 3%; right: 4%;"))
                  (gui '(+JS +Button) "copy") )
               (<style> '("clipInputArea tiny submit" (style . "position: absolute; top: 7%; right: 4%;"))
                  (gui '(+JS +Button) ":{ ... }") )
               (<style> '("lilInputArea" (placeholder . " or here"))
                  (gui 'area '(+Mono +FileField)
                     (: lyrepl)
                     (*/ DX 4 5) 30 ) ) ) )

         # resize / close buttons (absolute positioned top right)
         (<style> '(style . "position: absolute; top: 12px; right: 34px; padding: 2px 1px;")
            (gui '(+Style +Tip +Button) "mono" "exit fullscreen" "[-]"
               '(prog
                  (off *FullscreenRepl)
                  (url (pack (ext.html (get *Top 'obj)) "?*Menu=+0&*Tab=+2&*ID=$edit")) ) ) )
         (<style> '(style . "position: absolute; top: 12px; right: 2px;")
            (gui '(+Style +Button) "closeRepl right" "x"
               '(prog (rollback) (off *ID)) ) )


         # (<div> '(flex-col (id . "ReplSvgContainerFullscreen") (style . "flex-grow: 1;"))
         #    (<tab>
         #       ("music"
         #          (<div> 'flex-row
         #             (<style> '(placeholder . "<FILENAME>")
         #                (gui 'nm '(+TextField) 20) )
         #             (gui '(+Button) "Save As"
         #                # upload current repl.svg to document
         #                # feels like a hack, but it works
         #                '(ifn (val> (: home nm))
         #                   (error "Please specify a name")
         #                   (put!> (get *Top 'obj 'mup) 'bin
         #                      (cons
         #                         (prog1
         #                            (new! '(+Bin) 'nm (val> (: home nm)))
         #                            (blob! @ 'd "wiki/img/repl.cropped.svg") )
         #                         (get *Top 'obj 'mup 'bin) ) )
         #                   # reload page so new svg appears in media chart
         #                   (url (pack (ext.html (get *Top 'obj)) "?*Menu=+0&*Tab=+2&*ID=$edit")) ) ) )
         #                # can't use '(url *Url)' because *Url seems to be inconsistent.
         #                # sometimes it is "!ping" other times it is "!ssEvt" (because lilRepl
         #                # creates an SSE). all this is probably because I don't *really* understand
         #                # how to use the PL form/gui stuff, I just hack away until the desired results
         #                # are achieved.
         #          (<ReplSvgDivFullscreen>) )
         #       ("debug"
         #          (gui 'view '(+Style +Able +FileField)
         #             "ReplOutputFullscreen"
         #             '(<> (: file) (: home repl))
         #             (: repl)
         #             DX DY ) ) ) )

         (<MetaReplFullscreenMusicDebugTabs>)
         ) ) )


# (de <MetaReplFullscreenMusicDebugTabs> ()
#    # BUTTONS
#    (<div> 'tabs
#       (<htmlbutton> '("tabBtn top" (id . "musicBtn") (onclick . "openTab('musicTab')")) "music")
#       (<htmlbutton> '("tabBtn"     (id . "debugBtn")  (onclick . "openTab('debugTab')"))  "debug") )
#    # VIEWS
#    (<div> '("tabView top" (id . "musicTab"))
#       (<div> '(flex-col (id . "ReplSvgContainerFullscreen") (style . "flex-grow: 1;"))
#          (<div> 'flex-row
#             (<style> '(placeholder . "<FILENAME>")
#                (gui 'nm '(+TextField) 20) )
#             (gui '(+Button) "Save As"
#                # upload current repl.svg to document
#                # feels like a hack, but it works
#                '(ifn (val> (: home nm))
#                   (error "Please specify a name")
#                   (put!> (get *Top 'obj 'mup) 'bin
#                      (cons
#                         (prog1
#                            (new! '(+Bin) 'nm (val> (: home nm)))
#                            (blob! @ 'd "wiki/img/repl.cropped.svg") )
#                         (get *Top 'obj 'mup 'bin) ) )
#                   # reload page so new svg appears in media chart
#                   (url (pack (ext.html (get *Top 'obj)) "?*Menu=+0&*Tab=+2&*ID=$edit")) ) ) )
#                # can't use '(url *Url)' because *Url seems to be inconsistent.
#                # sometimes it is "!ping" other times it is "!ssEvt" (because lilRepl
#                # creates an SSE). all this is probably because I don't *really* understand
#                # how to use the PL form/gui stuff, I just hack away until the desired results
#                # are achieved.
#          (<ReplSvgDivFullscreen>) ) )
#    (<div> '("tabView" (id . "debugTab") (style . "display: none;"))
#       (gui 'view '(+Style +Able +FileField)
#          "ReplOutputFullscreen"
#          '(<> (: file) (: home repl))
#          (: repl)
#          DX DY ) ) )

(de <MetaReplFullscreenMusicDebugTabs> ()
   (<div> '(flex-col (id . "ReplSvgContainerFullscreen") (style . "margin-top: 8px; flex-grow: 1;"))
      (<div> 'tabcontainer
         (<div> '(flex-row (style . "justify-content: flex-start;"))
            # buttons
            (<htmlbutton>
               '("tab active"
                  (id . "tab1")
                  (tab-index . 0)
                  (role . "tab")
                  (aria-controls . "tabpane1")
                  (aria-selected . "true")
               )
               "music" )
            (<htmlbutton>
               '("tab"
                  (id . "tab2")
                  (tab-index . 0)
                  (role . "tab")
                  (aria-controls . "tabpane2")
                  (aria-selected . "false")
               )
               "debug" )
            )
         # views
         (<div> NIL
            (<div>
               '("tabpane active"
                  (id . "tabpane1")
                  (role . "tabpanel")
                  (aria-labelledby . "tab1")
                  (aria-hidden . "false")
               )
               (<div> '(flex-row (style . "margin-top: 8px"))
                  (<style> '(placeholder . "<filename>")
                     (gui 'nm '(+TextField) 20) )
                  (<style> '(style . "margin: 0px 8px")
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
                           # reload page so new svg appears in media chart
                           (url (pack (ext.html (get *Top 'obj)) "?*Menu=+0&*Tab=+2&*ID=$edit")) ) ) ) )
                        # can't use '(url *Url)' because *Url seems to be inconsistent.
                        # sometimes it is "!ping" other times it is "!ssEvt" (because lilRepl
                        # creates an SSE). all this is probably because I don't *really* understand
                        # how to use the PL form/gui stuff, I just hack away until the desired results
                        # are achieved.
                  (<ReplSvgDivFullscreen>) )
            (<div>
               '("tabpane"
                  (id . "tabpane2")
                  (role . "tabpanel")
                  (aria-labelledby . "tab2")
                  (aria-hidden . "true")
                  (hidden . "true")
                  (style . "margin-top: 9px")
                  )
               (gui 'view '(+Style +Able +FileField)
                  "debugView"
                  '(<> (: file) (: home repl))
                  (: repl)
                  DX 32 ) ) ) ) ) )

(de <ReplSvgDiv> ()
   (<div> '(id . ReplSvg)
      (<ReplSvg>) ) )

(de <ReplSvgDivFullscreen> ()
   (<div> '(id . ReplSvgFullscreen)
      (<ReplSvg>) ) )


(de <ReplSvg> ()
   # see https://stackoverflow.com/questions/1077041/refresh-image-with-a-new-one-at-the-same-url/9943419#9943419
   # '(date)' and '(time)' to fool browser cache and update image
   (<img> (pack "http://localhost:" *WikiPort "/wiki/img/repl.cropped.svg#" (date) (time))) )


# send latest SVG to the browser
(de updReplSvg ()
   (if *FullscreenRepl
      (serverSend *ReplSvgFullscreen (<ReplSvg>))
      (serverSend *ReplSvg (<ReplSvg>)) ) )


# write lilypond file
(de ly Music
   (out (tmp "repl.ly")
      (lyVersion)
      (lyLayout)
      (run Music) )
   (call *Lily "--loglevel=WARN" "-dcrop" "-dbackend=svg" "--output=wiki/img" (tmp "repl.ly"))
   (updReplSvg)
   T )

(de lyEcho ()
   (in (tmp "repl.ly") (echo)) )
