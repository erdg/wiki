# 04jan19abu
# (c) Software Lab. Alexander Burger

# Download blob
(de getBlob (This)
   (ifn (: nm)
      (notAllowed "getBlob")
      (httpHead (: mt) 60 (: nm))
      (in (blob This 'd) (ht:Out *Chunked (echo))) ) )

# Retrieve document history
(be history (@Doc @Mup)
   (val @Mup @Doc mup) )

(be history (@Doc @Mup)
   (^ @C (box (; (-> @Doc) mup)))
   (_history @C @Mup) )

(be _history (@C @Prv) (^ @ (not (; (val (-> @C)) <))) T (fail))
(be _history (@C @Prv) (^ @Prv (set (-> @C) (; (val (-> @C)) <))))
(repeat)

# Search field hint list
(def 'search 'hint
   '((Str)
      (make
         (catch NIL
            (scan '(mup . +Doc)
               '((K V)
                  (unless (member (car K) (made))
                     (link (car K))
                     (and (nth (made) 24) (throw)) ) )
               (cons (setq Str (fold Str)))
               (cons (pack Str `(char T)) T) ) ) ) ) )

# Split list of characters into folded words
(de splitWords (Lst)
   (extract fold
      (mapcar pack
         (split Lst ~(chop "^J !,-.:;?{}")) ) ) )

# Get markup's title
(dm (title> . +Mup) ()
   (in (blob This 'txt)
      (skip)
      (use (@N @X)
         (and
            (match '(@N "{" @X "}" @) (line))
            (format @N)
            (pack @X) ) ) ) )

# Render document as HTML
(de render (Bin)
   (let Nest NIL
      (recur (Nest)
         (use C
            (loop
               (ht:Prin (till "^J123456&/!_*+-%~|<@>=\^:$\\#}" T))
               (NIL (setq C (char)))
               (T (and Nest (= C "}")))
               (unless (= C "\\")
                  (case (peek)
                     ("^J"
                        (ifn (= "^J" C)
                           (ht:Prin C)
                           (----)
                           (char) ) )
                     ("{"
                        (char)  # Skip "{"
                        (case C
                           (("1" "2" "3" "4" "5" "6")  # Heading
                              (_render "h" C)
                              (prinl)
                              (skip) )
                           ("&"  # Line break
                              (let? N (format (till "}" T))
                                 (prin "<br"
                                    (and (lt0 N) " class=\"clr\"")
                                    "/>" )
                                 (do (dec (abs N))
                                    (prin "<br/>") ) )
                              (char) )
                           ("/"  # Italic
                              (_render "i") )
                           ("!"  # Bold
                              (_render "b") )
                           ("_"  # Underlined
                              (_render "u") )
                           ("*"  # Unordered list
                              (_render "ul") )
                           ("+"  # Ordered list
                              (_render "ol") )
                           ("-"  # List item
                              (_render "li") )
                           ("%"  # Table
                              (prin "<table class=\"wiki\">")
                              (recurse T)
                              (prin "</table>") )
                           ("~"  # Table row
                              (_render "tr") )
                           ("|"  # Table data
                              (_render "td") )
                           ("$"  # CSS style
                              (<div> (cons 'style (till "^I^J^M}" T))
                                 (char)
                                 (recurse T) ) )
                           (("<" "@" ">")  # Binary file
                              (let Nm (till "}" T)
                                 (char)
                                 (with (findBin Nm Bin)
                                    (cond
                                       ((pre? "image/" (: mt))
                                          (prin "<img src=\""
                                             *SesId (blob This 'd)
                                             "\" alt=\"" )
                                          (ht:Prin Nm)
                                          (prin "\" loading=\"lazy")
                                          (prin
                                             "\" class=\""
                                             (case C
                                                ("<" "left")
                                                ("@" "nofloat")
                                                (">" "right") )
                                             "\"/>" ) )
                                       ((pre? "audio/" (: mt))
                                          (prin "<audio src=\""
                                             *SesId (blob This 'd)
                                             "\" class=\""
                                             (case C
                                                ("<" "left")
                                                ("@" "nofloat")
                                                (">" "right") )
                                             "\" preload=\"none\" controls>" )
                                          (ht:Prin Nm)
                                          (prin "</audio>") )
                                       ((or
                                             (pre? "video/" (: mt))
                                             (pre? "application/ogg;" (: mt)) )
                                          (prin "<video src=\""
                                             *SesId (blob This 'd)
                                             "\" class=\""
                                             (case C
                                                ("<" "left")
                                                ("@" "nofloat")
                                                (">" "right") )
                                             "\" preload=\"none\" controls>" )
                                          (ht:Prin Nm)
                                          (prin "</video>") )
                                       (T
                                          (<style> (cons 'type (: mt))
                                             (<href> Nm (pack "!getBlob?" (ht:Fmt This))) ) ) ) ) ) )
                           ("="  # Internal document link
                              (wikiLink (split (till "}") " " "^I" "^J" "^M"))
                              (char) )
                           ("\^"  # External web link
                              (let S (split (till "}") " " "^I" "^J" "^M")
                                 (char)
                                 (if
                                    (member
                                       (car (split (car S) ":"))
                                       (quote
                                          `(chop "http")
                                          `(chop "https")
                                          `(chop "irc")
                                          `(chop "mailto") ) )
                                    (<href>
                                       (or (glue " " (cdr S)) (pack (car S)))
                                       (pack (car S)) )
                                    (prin "???") ) ) )
                           # (":"  # Pre-formatted
                           #    ((if (= "^J" (peek)) <pre> <span>) '(code (title . "click to copy"))
                           #       (renderBlock ht:Prin)) )
                           (":"  # Pre-formatted
                              (let Peek (= "^J" (peek))
                                 ((if Peek <pre> <span>)
                                    (list 'code
                                       (if Peek '(title . "click to copy"))
                                       (and Peek (not *DisplayDocumentCode) '(style . "display: none;")) )
                                    (renderBlock ht:Prin)) ) )
                           ("\\" (prin "{"))  # Escaped brace
                           ("#" (renderBlock prog))  # Comment
                           (T (prin C "{")) ) )
                     (T (ht:Prin C)) ) ) ) ) ) ) )

(de _render (C D)
   (prin "<" C D ">")
   (recurse T)
   (prin "</" C D ">") )

(de renderBlock (Fun)
   (let (N 0  C)
      (loop
         (NIL (setq C (char)))
         (while (= "\\" C)
            (Fun (char))
            (setq C (char)) )
         (T (and (=0 N) (= "}" C)))
         (case (Fun C)
            ("{" (inc 'N))
            ("}" (dec 'N)) ) ) ) )

# Render document as LaTeX
(de renderLatex (This)
   (prinl "% " (datSym (date)))
   (prinl "% " (or (: u name) (: u nm)))
   (prinl)
   (tex "documentclass[10pt,a4paper]" "article")
   (tex "usepackage" "graphicx")
   (prinl)
   (prinl "\\textwidth 1.4\\textwidth")
   (prinl "\\textheight 1.125\\textheight")
   (prinl "\\oddsidemargin 0em")
   (prinl "\\evensidemargin 0em")
   (prinl "\\headsep 0em")
   (prinl "\\parindent 0em")
   (prinl "\\parskip 6pt")
   (prinl)
   (and (title> This) (tex "title" @))
   (let A This
      (while (and (; A min) (; A <))
         (setq A @) )
      (let B A
         (while (; B <)
            (setq B @) )
         (setq A (; A u)  B (; B u))
         (if (== A B)
            (tex "author"
               (or (; A name) (; A nm))
               (; A em) )
            (texl "author"
               (list
                  (or (; B name) (; B nm))
                  (; B em) )
               " \\and "
               (list
                  (or (; A name) (; A nm))
                  (; A em) ) ) ) ) )
   (tex "date" (datStr (: d)))
   (prinl)
   (\\block "document"
      (tex "maketitle")
      (prinl)
      (in (blob This 'txt)
         (let Nest NIL
            (recur (Nest)
               (use C
                  (loop
                     (texPrin (till "^J123456&/!_*+-<@>=\^:\\#}" T))
                     (NIL (setq C (char)))
                     (T (and Nest (= C "}")))
                     (unless (= C "\\")
                        (ifn (= "{" (peek))
                           (texPrin C)
                           (char)  # Skip "{"
                           (case C
                              (("1" "2" "3" "4" "5" "6")  # Heading
                                 (_latex (if (>= "3" C) "section*" "subsection*")) )
                              ("&"
                                 (do (format (till "}" T))
                                    (prin "\\\\") )
                                 (char) )
                              ("/"  # Italic
                                 (_latex "textit") )
                              ("!"  # Bold
                                 (_latex "textbf") )
                              ("_"  # Underlined
                                 (_latex "underline") )
                              ("*"  # Unordered list
                                 (skip)
                                 (\\block "itemize"
                                    (space 3)
                                    (recurse T)
                                    (char) ) )
                              ("+"  # Ordered list
                                 (skip)
                                 (\\block "enumerate"
                                    (space 3)
                                    (recurse T)
                                    (char) ) )
                              ("-"  # List item
                                 (prin "\\item ")
                                 (recurse T) )
                              (("<" "@" ">")  # Binary file
                                 (let Nm (till "}" T)
                                    (char)
                                    (with (findBin Nm (: bin))
                                       (ifn (pre? "image/" (: mt))
                                          (texPrin Nm)
                                          (call 'convert (blob This 'd) (tmp "img.pdf"))
                                          (\\figure "[h]"
                                             (\\block
                                                (case C
                                                   ("<" "flushleft")
                                                   ("@" "center")
                                                   (">" "flushright") )
                                                (tex "includegraphics" "img.pdf") ) ) ) ) ) )
                              (("=" "\^")  # Internal document / External web link
                                 (let S (split (till "}") " " "^I" "^J" "^M")
                                    (char)
                                    (tex NIL "underline" (or (glue " " (cdr S)) (car S)))
                                    (tex NIL "footnote"
                                       (if (= "=" C)
                                          (srcUrl (pack "?" (car S)))
                                          (car S) ) ) ) )
                              (":"  # Pre-formatted
                                 (if (= "^J" (peek))
                                    (prog
                                       (char)
                                       (\\block "verbatim" (renderBlock prin)) )
                                    (prin "\\texttt{")
                                    (renderBlock
                                       '((C)
                                          (and (sub? C "{}") (prin "\\"))
                                          (prin C) ) )
                                    (prin "}") ) )
                              ("\\" (prin "{"))  # Escaped brace
                              ("#" (renderBlock prog))  # Comment
                              (T (prin C "{")) ) ) ) ) ) ) ) ) ) )

(de _latex (S)
   (prin "\\" S "{")
   (recurse T)
   (prin "}") )

# Produce LaTeX document
(de latex (This)
   (ifn (ext? This)
      (noContent)
      (httpHead "application/x-latex" 20 (pack (or (: doc nm) "untitled") ".tex"))
      (ht:Out *Chunked (renderLatex This)) ) )

# Produce PDF document
(de pdf (This)
   (ifn (ext? This)
      (noContent)
      (let Nm (or (: doc nm) "untitled")
         (out (tmp Nm ".tex") (renderLatex This))
         (chdir (tmp)
            (in (list "/usr/bin/pdflatex" "-interaction=batchmode" Nm))
            (httpEcho (pack Nm ".pdf") "application/pdf" 20) ) ) ) )

# vi:et:ts=3:sw=3
