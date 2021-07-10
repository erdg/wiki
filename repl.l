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
            background: #131423;
            margin: 0 auto;
            top: 0px;
            left: 0px;
            width: 100%;
            height: 100%;
            overflow: auto;
            border-radius: 0px;
            z-index: 99" ) ) ) )

(de <MetaReplHeader> ()
   (<div> '(flex-row (id . "metaReplHeader") (style . "justify-content: flex-start; margin-right: 64px;"))
      # (<style> '(style . "width: 32px;")
      #    (<img> "wiki/img/small-logo.png") )
      # (<p> '(id . "replHeaderText")
      #       "metaRepl" )
      (<p> '(id . "replHeaderText")
            "edit" )
      # tab buttons
      (<div> 'tabs
         (<style>
            (list
               (pack "tabBtn" (if (= *CurrentTab "document") " top"))
               '(id . "documentBtn")
               '(onclick . "openTab('document')") )
            (<href> "document" "!setCurrentTab?document") )
         (<style>
            (list
               (pack "tabBtn" (if (= *CurrentTab "music") " top"))
               '(id . "musicBtn")
               '(onclick . "openTab('music')") )
            (<href> "music" "!setCurrentTab?music") )
         # (<style>
         #    (list
         #       (pack "tabBtn" (if (= *CurrentTab "picolisp") " top"))
         #       '(id . "picolispBtn")
         #       '(onclick . "openTab('picolisp')") )
         #    (<href> "picolisp" "!setCurrentTab?picolisp") )
      )
   )
)

(allow "!setCurrentTab")
(de setCurrentTab (Tab)
   (setq *CurrentTab Tab)
   (noContent) )

(once (setq *CurrentTab "document"))

(de <MetaReplTabs> ()
   # tab views
   (<div> (list "tabView" '(id . "document") (ifn (= *CurrentTab "document") '(style . "display: none;")))
      (form 'edit-tab
         (=: obj Obj)
         # (<h3> NIL (ht:Prin (: obj nm)))
         (docFields T) ) )
   (<div> (list "tabView" '(id . "picolisp") (ifn (= *CurrentTab "picolisp") '(style . "display: none;")))
      (pilRepl (if *FullscreenRepl 'PilReplFullscreen) 56 20) )
   (<div> (list "tabView" '(id . "music") (ifn (= *CurrentTab "music") '(style . "display: none;")))
      (if *FullscreenRepl
         (lilReplFullscreen NIL 56 20)
         (lilRepl NIL 56 10) ) )
   # (<div> '("tabView" (id . "options") (style . "display: none;"))
   #    (form NIL
   #       (<div> 'flex-col
   #          (<style> '(style . "margin: 4px 8px")
   #             (gui '(+Style +Button) "themeToggle" "Light/Dark Mode"
   #                '(prog
   #                   (rot *WikiCss)
   #                   (url (pack (ext.html (get *Top 'obj)) "?*Menu=+0&*Tab=+2&*ID=$edit")) ) )
   #             (gui '(+Button) "Toggle Document Code Sections"
   #                '(prog
   #                   (onOff *DisplayDocumentCode)
   #                   (url (pack (ext.html (get *Top 'obj)) "?*Menu=+0&*Tab=+2&*ID=$edit")) ) ) ) ) ) )
   )

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
      (<style> '(style . "margin: 8px 0px")
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
         (<style> '(style . "margin-left: 4px")
            (gui '(+JS +Button)
               '(if (= (: home view file) (: home repl)) ,"Edit" ,"Done")
               '(file> (: home view)
                  (if (= (: home view file) (: home repl))
                     (if (val> (: home line))
                        (setq *ReplF (push1 '*ReplH @))
                        (set> (: home line) *ReplF)
                        *ReplF )
                     (clr> (: home line))
                     (: home repl) ) ) ) ) )
      (<style> '(style . "margin-top: 8px")
         (gui 'line '(+Able +Mono +TextField)
            '(= (: home view file) (: home repl))
            (*/ DX 4 5) ) )
      # (--)

      # resize / close buttons (top right)
      (<style> '(style . "position: absolute; top: 8px; right: 30px;")
         (if *FullscreenRepl
            (gui '(+Style +Tip +Button) "mono" "Exit Fullscreen" "-"
               '(prog
                  (off *FullscreenRepl)
                  (url (pack (ext.html (get *Top 'obj)) "?*Menu=+0&*Tab=+2&*ID=$edit")) ) )
            (gui '(+Style +Tip +Button) "mono" "Fullscreen" "+"
               '(prog
                  (on *FullscreenRepl)
                  (url (pack (ext.html (get *Top 'obj)) "?*Menu=+0&*Tab=+2&*ID=$edit")) ) ) ) )
      (<style> '(style . "position: absolute; top: 8px; right: 0px;")
         (gui '(+Style +Button) "closeRepl right" "x"
            '(prog (rollback) (off *ID)) ) ) ) )


# lilypond repl
(de lilRepl (Attr DX DY)
   (default DX 80  DY 25)
   (serverSentEvent "ReplSvg" '*ReplSvg)
   (form Attr
      (=: repl (tmp "repl"))
      (=: lyrepl (tmp "lyrepl"))

      # code / touch input tabs (using 'stabs.js')
      (<div> '(tabcontainer (style . "margin-bottom: 16px;"))

         # input [ touch ] [ code ]
         (<p> '(mono (style . "display: inline; font-size: 14px;")) "input")
         (<div> '(flex-row (style . "display: inline-flex; margin-bottom: 16px; justify-content: flex-start;"))
            # buttons
            (<htmlbutton>
               '("tab active"
                  (id . "touchTabBtn")
                  (tab-index . 0)
                  (role . "tab")
                  (aria-controls . "touchTabView")
                  (aria-selected . "true") )
               "touch" )
            (<htmlbutton>
               '("tab"
                  (id . "codeTabBtn")
                  (tab-index . 0)
                  (role . "tab")
                  (aria-controls . "codeTabView")
                  (aria-selected . "false") )
               "code" ) )

         # views
         (<div> NIL

            # touch input view
            (<div>
               '("tabpane active"
                  (id . "touchTabView")
                  (role . "tabpanel")
                  (aria-labelledby . "touchTabBtn")
                  (aria-hidden . "false")
                  (style .
                     "position: relative;
                     width: 340px;
                     height: 460px;
                     background: #faf5f0;
                     border: 1px solid #ddd;
                     border-radius: 4px;" ) )

               # js to communicate between <object> and parent window (because cors).
               # <object> uses 'window.parent.postMessage()' to trigger js 'fetch', which
               # calls the lisp fn 'updTouchSvg'.
               (<javascript>
                  (pack
                     "window.addEventListener('message', function (e) {
                        if (typeof(e.data) !== 'string') return;
                        console.log(e.data + ' ' + e.origin);
                        if (e.origin == 'http://localhost:5000' || e.origin == 'https://erikdgustafson.com') {
                           fetch(window.location.href.split('~')[0] + '~!setTouchNote?' + e.data);
                        } else {
                           return;
                        }
                     }, false);" ) )
               # see also lisp fn 'lilypondNoteIconSVG', which generates the svgs (with
               # the actual js 'postMessage' call)

               # treble clef background (kinda prevents flicker as svg is updated)
               (<div> '(style . "position: absolute; top: 100px; left: 0px;")
                  (<object> (pack *WikiFullUrl "/wiki/img/svg2/treble-clef.svg")) )

               # _the_ svg (updated via 'serverSend)
               (serverSentEvent "TouchSvg" '*TouchSvg)
               (<div> '((id . "TouchSvg") (style . "position: absolute; top: 100px; left: 0px;"))
                  (<object>
                     (pack *WikiFullUrl "/wiki/img/svg2/" (currentTouchFile) "-treble.svg") ) )

               # buttons
               (<div> '(flex-col
                        (id . "touchSvgButtons")
                        # (style . "position: absolute; z-index: 20; top: 12px; left: 16px;")
                        )
                  (<div> '(flex-row (style . "position: relative; width: 300px;"))
                     (<style> '(style . "font-size: 14px; font-style: italic;")
                        (gui '(+Mono +JS +Button) "add as rest"
                           '(touchMelodyAddRest (pack "r" *TouchDuration *TouchDots)) ) )
                     # (<div> 'flex-row
                     #    # rests
                     #    (gui '(+JS +Button) "𝄻" '(touchMelodyAddRest "r1"))
                     #    (gui '(+JS +Button) "𝄼" '(touchMelodyAddRest "r2"))
                     #    (gui '(+JS +Button) "𝄽" '(touchMelodyAddRest "r4"))
                     #    (gui '(+JS +Button) "𝄾" '(touchMelodyAddRest "r8"))
                     #    (gui '(+JS +Button) "𝄿" '(touchMelodyAddRest "r16"))
                     #    (gui '(+JS +Button) "𝅀" '(touchMelodyAddRest "r32")) )
                     # dot-menu -- undo, clear melody
                     (<div> '("dot-menu collapsible" (style . "position: absolute; right: 0px;"))
                        NIL )
                     (<div> "collapsible-content"
                        (gui '(+JS +Button) "undo"
                           '(prog
                              (rot *TouchMelody)
                              (++ *TouchMelody)
                              (out (: home lyrepl) (prin "{ " (glue " " *TouchMelody) " }"))
                              (ly
                                 (prog
                                    (when (val> (: home renderFont))
                                       (list (any (pack 'ly @ 'Font))) )
                                    (eval
                                       (progLilypond) ) ) ) ) )
                        (gui '(+JS +Button) "clear melody"
                           '(prog
                              (off *TouchMelody)
                              (out (: home lyrepl) (prin "(lleadsheet-ap " (glue " " *TouchMelody) " )"))
                              (ly
                                 (prog
                                    (when (val> (: home renderFont))
                                       (list (any (pack 'ly @ 'Font))) )
                                    (eval
                                       (progLilypond) ) ) ) ) ) ) )
                  (<div> 'flex-row
                     # durations
                     (gui '(+JS +Button) "𝅝" '(setTouchDuration 1))
                     (gui '(+JS +Button) "𝅗𝅥" '(setTouchDuration 2))
                     (gui '(+JS +Button) "𝅘𝅥" '(setTouchDuration 4))
                     (gui '(+JS +Button) "𝅘𝅥𝅮" '(setTouchDuration 8))
                     (gui '(+JS +Button) "𝅘𝅥𝅯" '(setTouchDuration 16))
                     (gui '(+JS +Button) "𝅘𝅥𝅰" '(setTouchDuration 32))
                     (<style> '(style . "margin-left: 16px;")
                        (gui '(+JS +Button) "." '(incTouchDots)) )
                     (<style> '(style . "font-size: 12px; padding: 20px 0px 4px 6px;")
                        (gui '(+JS +Button) "x" '(offTouchDots)) ) )

                  # "add chord" button
                  (<div> '(flex-row (style . "position: absolute; top: 140px;"))
                     (<style> '((style . "font-size: 16px; font-style: italic; color: #000; background: unset;"))
                        (gui '(+Style +Mono +JS +Button) "touchModalBtn" "add chord") )
                     # a modal appears
                     (<div> "collapsible-content modal"
                        (<div> 'modal-inner
                           (<p> '((style . "font-size: 20px; margin: 0px;")) "Add chord")
                           (<style> '(placeholder . "e.g. e:min7")
                              (gui 'chord '(+Style +TextField) "touchChord" 16) )
                           (--)
                           (gui '(+OnClick +Button)
                              "document.getElementsByClassName('modal')[0].style.maxHeight = null;"
                              "Ok"
                              '(prog
                                 (queue '*TouchMelody (val> (: home chord)))
                                 (set> (: home chord) "")
                                 (out (: home lyrepl) (prin "(lleadsheet-ap " (glue " " *TouchMelody) " )"))
                                 (ly
                                    (prog
                                       (eval
                                          (progLilypond) ) ) )
                                 (updReplSvg) ) )
                           (gui '(+OnClick +Button)
                              "document.getElementsByClassName('modal')[0].style.maxHeight = null;"
                              "Cancel" )
                           ) ) )

#                   # dynamics button
#                   (<div> '(flex-row (style . "position: absolute; top: 350px;"))
#                      (<style> '(style . "font-size: 14px;")
#                         (gui '(+Mono +JS +Button) "dynamics") ) )

#                   # accents / articulations
#                   (<div> '(flex-row (style . "position: absolute; top: 380px;"))
#                      (<style> '(style . "font-size: 14px;")
#                         (gui '(+Mono +JS +Button) "accents") ) )

                  (<div> '(flex-col (style . "position: absolute; top: 196px; left: 234px;"))
                     # octave up
                     (gui '(+JS +Button) "𝄶"
                        '(setTouchOctave (+ *TouchOctave 1)) )
                     # accidentals
                     (<div> 'flex-row
                        (gui '(+JS +Button) "♯" '(setTouchAccidental "is"))
                        (gui '(+JS +Button) "♮" '(setTouchAccidental ""))
                        (gui '(+JS +Button) "♭" '(setTouchAccidental "es")) )
                     # octave down
                     (gui '(+Mono +JS +Button) "𝄷"
                        '(setTouchOctave (- *TouchOctave 1)) ) )

               )

               # add to melody
               (<div> '(id . "touchSvgFab")
                  (gui '(+JS +Button) " "
                     '(prog
                        (queue '*TouchMelody (currentTouchNote))
                        # (out (: home lyrepl) (prin Str))
                        (out (: home lyrepl) (prin "(lleadsheet-ap " (glue " " *TouchMelody) " )"))
                        (ly
                           (prog
                              (when (val> (: home renderFont))
                                 (list (any (pack 'ly @ 'Font))) )
                              (eval
                                 (progLilypond) ) ) )
                        (setq *TouchDots NIL )
                        (updTouchSvg) ) ) )
               )

            (<div>
               '("tabpane"
                  (id . "codeTabView")
                  (role . "tabpanel")
                  (aria-labelledby . "codeTabBtn")
                  (aria-hidden . "true")
                  (hidden . "true") )

               # Run line
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
                                                               (progLilypond) ) ) ) ) ) ) ) )
                                    (off *Msg)
                                    (println '-> "@1") ) )
                              (and *Msg (prinl @)) ) )
                        (push1 '*ReplH Str) ) )

                  (<style> '((style . "flex-grow: 1; margin: 8px 8px;") (placeholder . "code here") )
                     (gui 'line '(+Mono +TextField)
                        (*/ DX 4 5) ) ) )

               (<RunLineOptions>)

               # input area
               (<div> '(style . "position: relative;")
                  (<style> '("clipInputAreaRaw tiny" (style . "position: absolute; top: 6%; right: 4%;"))
                     (gui '(+JS +Button) "copy") )
                  # (<style> '("clipInputArea tiny submit" (style . "position: absolute; top: 16%; right: 4%;"))
                  #    (gui '(+JS +Button) ":{ ... }") )
                  (<style> '("lilInputArea" (placeholder . "or code here"))
                     (gui 'area '(+Mono +FileField)
                        (: lyrepl)
                        (*/ DX 4 5) 20 ) ) ) ) ) )
            ###

      # resize / close buttons (absolute positioned top right)
      (<style> '(style . "position: absolute; top: 8px; right: 30px;")
         (gui '(+Tip +Button) "Fullscreen" "+"
            '(prog
               (on *FullscreenRepl)
               (url (pack (ext.html (get *Top 'obj)) "?*Menu=+0&*Tab=+2&*ID=$edit")) ) ) )
      (<style> '(style . "position: absolute; top: 8px; right: 0px;")
         (gui '(+Style +Button) "closeRepl right" "x"
            '(prog (rollback) (off *ID)) ) )

      (<hr>)

      # music / debug output (using 'stabs.js')
      (<div> '(tabcontainer (style . "margin-top: 0px"))
         (<p> '(mono (style . "display: inline; font-size: 14px;")) "output")
         (<div> '(flex-row (style . "display: inline-flex; margin-bottom: 8px; justify-content: flex-start;"))
            # buttons
            (<htmlbutton>
               '("tab active"
                  (id . "tab1")
                  (tab-index . 0)
                  (role . "tab")
                  (aria-controls . "tabpane1")
                  (aria-selected . "true")
               )
               "image" )
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
               (<spread>
                  (<style> '(placeholder . "<filename>")
                     (gui 'nm '(+Style +Mono +TextField) "saveAsLine" 20) )
                  (gui '(+Style +Button) "saveAsButton" "Save As"
                     # upload current repl.svg to document
                     # feels like a hack, but it works
                     '(ifn (val> (: home nm))
                        (error "Please specify a name")
                        (prog
                           (put!> (get *Top 'obj 'mup) 'bin
                              (cons
                                 (prog1
                                    (new! '(+Bin) 'nm (val> (: home nm)))
                                    (blob! @ 'd "wiki/img/repl.cropped.svg") )
                                 (get *Top 'obj 'mup 'bin) ) )
                           (setq *CurrentTab "document")
                           # reload page so new svg appears in media chart
                           (url (pack (ext.html (get *Top 'obj)) "?*Menu=+0&*Tab=+2&*ID=$edit")) ) ) ) )
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


# wrap lilypond input with implicit 'prog'
(de progLilypond ()
   (lytransform
      (append
         (cons
            (char 40)
            'prog
            (lyread (or (: home lyrepl) (tmp "lyrepl"))) )
         (list (char 41)) ) ) )


# Run line options - render, style, etc...
(de <RunLineOptions> ()
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

         # (<div> 'flex-col
         (<div> '(id . codeInputFullscreen)

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

               # Run line
               (<style> '("ReplLineFullscreen" (style . "flex-grow: 1; margin: 8px 8px;") (placeholder . "code here"))
                  (gui 'line '(+Mono +TextField)
                     (*/ DX 4 5) ) )

               (<RunLineOptions>) )

            (<div> '(style . "position: relative;")
               (<style> '("clipInputAreaRaw tiny submit" (style . "position: absolute; top: 3%; right: 4%;"))
                  (gui '(+JS +Button) "copy") )
               # (<style> '("clipInputArea tiny submit" (style . "position: absolute; top: 7%; right: 4%;"))
               #    (gui '(+JS +Button) ":{ ... }") )
               (<style> '("lilInputArea" (placeholder . " or here"))
                  (gui 'area '(+Mono +FileField)
                     (: lyrepl)
                     (*/ DX 4 5) 30 ) ) ) )

         # resize / close buttons (absolute positioned top right)
         (<style> '(style . "position: absolute; top: 8px; right: 30px;")
            (gui '(+Style +Tip +Button) "mono" "exit fullscreen" "-"
               '(prog
                  (off *FullscreenRepl)
                  (url (pack (ext.html (get *Top 'obj)) "?*Menu=+0&*Tab=+2&*ID=$edit")) ) ) )
         (<style> '(style . "position: absolute; top: 8px; right: 0px;")
            (gui '(+Style +Button) "closeRepl right" "x"
               '(prog (rollback) (off *ID)) ) )

         (<MetaReplFullscreenOutputTabs>)
         ) ) )

# using 'stabs.js'
(de <MetaReplFullscreenOutputTabs> ()
   (<div> '(flex-col (id . "ReplSvgContainerFullscreen") (style . "margin-top: 8px; flex-grow: 1;"))
      (<div> 'tabcontainer
         (<p> '(mono (style . "display: inline;")) "output")
         (<div> '(flex-row (style . "display: inline-flex; justify-content: flex-start;"))
            # buttons
            (<htmlbutton>
               '("tab active"
                  (id . "tab1")
                  (tab-index . 0)
                  (role . "tab")
                  (aria-controls . "tabpane1")
                  (aria-selected . "true")
               )
               "image" )
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
                     (gui 'nm '(+Style +Mono +TextField) "saveAsLine" 20) )
                  (<style> '(style . "margin: 0px 8px")
                     (gui '(+Style +Button) "saveAsButton" "Save As"
                        # upload current repl.svg to document
                        # feels like a hack, but it works
                        '(ifn (val> (: home nm))
                           (error "Please specify a name")
                           (prog
                              (put!> (get *Top 'obj 'mup) 'bin
                                 (cons
                                    (prog1
                                       (new! '(+Bin) 'nm (val> (: home nm)))
                                       (blob! @ 'd "wiki/img/repl.cropped.svg") )
                                    (get *Top 'obj 'mup 'bin) ) )
                              (off *FullscreenRepl)
                              (setq *CurrentTab "document")
                              # reload page so new svg appears in media chart
                              (url (pack (ext.html (get *Top 'obj)) "?*Menu=+0&*Tab=+2&*ID=$edit")) ) ) ) ) )
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
   (<img>
      (pack *WikiFullUrl "/wiki/img/repl.cropped.svg#" (date) (time)) ) )


# send latest SVG to the browser
(de updReplSvg ()
   (if *FullscreenRepl
      (serverSend *ReplSvgFullscreen (<ReplSvg>))
      (serverSend *ReplSvg (<ReplSvg>)) ) )

(allow "!updTouchSvg")
(de updTouchSvg ()
   (serverSend *TouchSvg
      (<object>
         (pack
            "http://localhost:"
            *WikiPort
            # "/wiki/img/svg/"
            "/wiki/img/svg2/"
            (currentTouchFile)
            "-treble.svg" ) ) ) )

(allow "!setTouchNote")
(de setTouchNote (Note)
   (noContent)
   (setq *TouchNote Note)
   (updTouchSvg) )

(de setTouchAccidental (Str)
   (setq *TouchAccidental Str)
   (updTouchSvg) )

(de setTouchOctave (N)
   (setq *TouchOctave N)
   (updTouchSvg) )

(de setTouchDuration (N)
   (setq *TouchDuration N)
   (updTouchSvg) )

(de incTouchDots ()
   (when (< (length *TouchDots) 2)
      (push '*TouchDots ".") )
   (updTouchSvg) )

(de offTouchDots ()
   (setq *TouchDots "")
   (updTouchSvg) )

# (de pushTouchMelody ()
#    (push '*TouchMelody (currentTouchNote))
#    (prog
#       # (out (: home lyrepl) (prin Str))
#       (out (tmp "lyrepl") (prin "{ " (glue " " *TouchMelody) " }")) )
#       (ly
#          (prog
#             # (when (val> (: home renderFont))
#             #    (list (any (pack 'ly @ 'Font))) )
#             (eval
#                (progLilypond) ) ) ) )

(de touchMelodyAddRest (Str)
   (prog
      (queue '*TouchMelody (pack Str *TouchDots))
      (offTouchDots)
      (out (: home lyrepl) (prin "{ " (glue " " *TouchMelody) " }"))
      (ly
         (prog
            (when (val> (: home renderFont))
               (list (any (pack 'ly @ 'Font))) )
            (eval
               (progLilypond) ) ) )
      (updTouchSvg) ) )

(allow "!offTouchMelody")
(de offTouchMelody ()
   (noContent)
   (off *TouchMelody) )

(de currentTouchNote ()
   (pack
      *TouchNote
      *TouchAccidental
      (number-to-octave-tick *TouchOctave)
      *TouchDuration
      *TouchDots ) )

(de currentTouchFile ()
   (pack
      *TouchNote
      *TouchAccidental
      (number-to-octave-tick *TouchOctave)
      *TouchDuration
      (need (length *TouchDots) "d") ) )

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

# html <object>
(de <object> (Url DX DY)
   (prin "<object data=\"" Url "\"")
   (and DX (prin " width=\"" DX "\""))
   (and DY (prin " height=\"" DY "\""))
   (and *Style (htStyle @))
   (prin ">")
   (prin "</object>") )
