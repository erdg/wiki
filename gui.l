# 02feb19abu
# (c) Software Lab. Alexander Burger

(de wiki (Nm)
   (nond
      (Nm (html> (db 'nm '+Doc "home")))
      ((db 'nm '+Doc (fold Nm)) (http404))
      (NIL (html> @)) ) )

(de menu (Ttl . Prg)
   (action
      (html 0 Ttl *Css NIL
         (<ping> 7)
         (<layout>
            ((180 0 'menu)
               (<div> @
                  (expires)
                  (<menu>
                     ("Wiki"
                        (if *Login
                           (baseHRef NIL *SesId "?home")
                           (baseHRef *Port1 "?home") ) )
                     ("Home" "!work")
                     ("logout" (and *Login "!stop"))
                     (NIL (<hr>))
                     ("Documents" (and (may Wiki) "wiki/doc.l"))
                     ("Role Administration" (and (may RoleAdmin) "@lib/role.l"))
                     ("User Administration" (and *Login "wiki/user.l") (unless (may UserAdmin) *Login))
                     ("Upload" (and (may Upload) "wiki/upload.l"))
                     ("Help" (and (may Wiki) "wiki/help.l")) ) )
               ((NIL NIL 'main)
                  (<div> @ (run Prg 1)) ) ) ) ) ) )

(de work ()
   (setq *Url "!work")
   (and (app) (setq *Menu 3))
   (menu "PicoLisp Wiki"
      (<h2> NIL "PicoLisp Wiki")
      (<img> "wiki/img/med-logo.png" "PicoLisp Logo")
      (----)
      (loginForm) ) )

(de stop ()
   (logout)
   (work) )

# Choose dialogs
(undef 'choUser)

(de choUser (Dst)
   (diaform '(Dst)
      (<grid> "--.-."
         "Login Name" (gui 'nm '(+Focus +Var +TextField) '*UserNm 10)
         "Full Name" (gui 'name '(+Var +DbHint +TextField) '*UserName '(name +User) 30)
         (searchButton '(init> (: home query)))
         "Created <=" (gui 'ca '(+Var +DateField) '*UserCa 10)
         "EMail" (gui 'em '(+Var +DbHint +TextField) '*UserEm '(em +User) 30)
         (resetButton '(nm name em ca new query))
         "New" (gui 'new '(+Var +Checkbox) '*UserNew) )
      (gui 'query '(+QueryChart) (cho)
         '(goal
            (quote
               @Nm *UserNm
               @Name *UserName
               @Em *UserEm
               @Ca (and *UserCa (cons @))
               @New *UserNew
               (select (@@)
                  ((nm +User @Nm) (name +User @Name)
                     (em +User @Em) (ca +User @Ca) (new +User @New) )
                  (head @Nm @@ nm)
                  (tolr @Name @@ name)
                  (fold @Em @@ em)
                  (range @Ca @@ ca)
                  (bool @New @@ new) ) ) )
         6
         '((This) (list This (: nm) This (: em) (: ca) (and (: new) "NEW"))) )
      (<table> 'chart (choTtl "Users" 'nm '+User)
         (quote
            (btn)
            (NIL "Login")
            (NIL "Full Name")
            (NIL "EMail")
            (NIL "Created") )
         (do (cho)
            (<row> (alternating)
               (gui 1 '(+DstButton) Dst)
               (gui 2 '(+TextField))
               (gui 3 '(+ObjView +TextField) '(: name))
               (gui 4 '(+MailField))
               (gui 5 '(+DateField))
               (gui 6 '(+TextField)) ) ) )
      (<spread>
         (scroll (cho))
         (newButton T Dst '(+User) 'nm *UserNm 'name *UserName)
         (cancelButton) ) ) )

(de choDoc (Dst)
   (diaform '(Dst)
      (<grid> "-.-."
         "Name" NIL (gui 'nm '(+Focus +Var +DbHint +TextField) '*DocNm '(nm +Doc) 30)
         (searchButton '(init> (: home query)))
         "Text" NIL (gui 'mup '(+Var +TextField) '*DocW 30)
         (resetButton '(nm mup usr query))
         "User" (choUser 0) (gui 'usr '(+Var +Obj +TextField) '*DocUsr '(nm +User) 30) )
      (gui 'query '(+QueryChart) (cho)
         '(goal
            (quote
               @D '(T)
               @Nm *DocNm
               @W (fold *DocW)
               @Usr *DocUsr
               (select (@@)
                  ((d +Mup @D doc)
                     (nm +Doc @Nm)
                     (mup +Doc @W)
                     (u +Mup @Usr doc) )
                  (head @Nm @@ nm)
                  (or
                     ((nil @W))
                     ((^ @ (fetch '(mup . +Doc) (cons @W (-> @@))))) )
                  (same @Usr @@ mup u) ) ) )
         7
         '((This)
            (list This This
               (: mup d) (: mup t) (: mup u)
               (: mup sum) (and (: mup min) "Minor edit") ) ) )
      (<table> 'chart (choTtl "Documents" 'nm '+Doc)
         '((btn) (NIL "Name") (NIL "Changed") NIL (NIL "by") (NIL "Summary"))
         (do (cho)
            (<row> (alternating)
               (gui 1 '(+DstButton) Dst)
               (gui 2 '(+ObjView +TextField) '(: nm))
               (gui 3 '(+DateField))
               (gui 4 '(+TimeField))
               (gui 5 '(+ObjView +TextField) '(: nm))
               (gui 6 '(+TextField))
               (gui 7 '(+TextField)) ) ) )
      (<spread>
         (scroll (cho))
         (newButton T Dst '(+Doc))
         (cancelButton) ) ) )

# Show document HTML page
(dm (html> . +Doc) ()
   (and (== 'login *ID) (app))
   (setq *Url (ext.html This))
   (if *Post
      (cookie 'search *Search)
      (default *Search (get *Cookies 'search)) )
   (action
      (html NIL (pack "Wiki: " (: nm)) *WikiCss NIL
         (<ping> 7)
         (<div> '(id . menu)
            (and (num? *ID) (tell @ 'logout))
            (<img> "wiki/img/small-logo.png" "Home"
               (if *Login
                  (baseHRef NIL *SesId "?home")
                  (baseHRef *Port1 "?home") ) )
            (when *WikiMenu
               (in (blob (; (id (car @) (cdr @)) mup) 'txt)
                  (render) ) )
            (<div> '(id . menuLogin)
               (ifn *Login
                  (<this> '*ID 'login "Log in")
                  (<href> "Log out"
                     (mkUrl (list (srcUrl *Url) '*ID *Pid)) )
                  (<$> "My account" *Login) ) )
            (<div> '(id . searchGrp)
               (<post> 'search *Url
                  # clear search button prototype
                  # (<span>
                  #    (quote
                  #       "submit"
                  #       (id . "clearSearch")
                  #       ("onclick" . "document.getElementById('search').setAttribute('value', '');
                  #                      document.getElementById('search').focus()" )
                  #       ("style" . "display: inline-block; border: none; font-size: small;") )
                  #    "x")
                  (<js>
                     (quote  # Emulate '+hint' field
                        ("autocomplete" . "off")
                        ("onfocus" . "doHint(this)")
                        ("onkeyup" . "return hintKey(this,event,true)") )
                     (<style> '(id . "search")
                        (<field> 24 '*Search) ) )
                  (<hidden> '*PRG T)
                  (<submit> "Search") )
               (when (chop *Search)
                  (searchWiki
                     (splitWords @)
                     (let L (split @ " ")
                        (unless (cddr L)  # 1 or 2 symbols
                           (mapcar '((S) (intern (pack S))) L) ) )
                     24 ) ) ) )
         (<div> '("container" (id . main))
            (cond
               ((== 'login *ID)
                  (<div> 'modal
                     (form 'login
                        (<grid> 2
                           "Username" (gui 'nm '(+Focus +TextField) 20)
                           "Password" (gui 'pw '(+PwField) 20) )
                        (--)
                        (gui '(+Button) "OK"
                           '(ifn (login (val> (: home nm)) (val> (: home pw)))
                              (error "Permission denied")
                              (put!> *Login 'new NIL)
                              (clr> (: home pw))
                              (off *ID) ) )
                        (gui '(+Button) "Cancel" '(off *ID))
                        # createAccountDialog goes here
                        (<nbsp> 7) ) ) )
               ((== 'edit *ID)
                  (let Obj This
                     (ifn (lock Obj)
                        (<div> NIL
                           # (repl '(id . "repl") 56 12)
                           (metaRepl)
                           (form 'edit
                              (=: obj Obj)
                              (<h3> NIL (ht:Prin (: obj nm)))
                              (docFields T) ) )
                        (<h2> 'red
                           (prinl
                              "This document is currently edited by user '"
                              (cdr (lup *Users @))
                              "'" ) ) ) ) )
               ((== 'rpl *ID)
                  (let Org This
                     (form 'edit
                        (=: org Org)
                        (<h3> NIL (ht:Prin "Reply"))
                        (docFields T) ) ) )
               ((str? *ID)
                  (if (fetch '(nm . +Doc) @)
                     (setq This @)  # Created meanwhile
                     (form 'edit
                        (=: docNm *ID)
                        (<h2> NIL "New document '" *ID "'")
                        (<p> NIL "This document doesn't exist yet")
                        (gui '(+Button) "Create document"
                           '(let Doc (request! '(+Doc) 'nm (fold (: home docNm) 0))
                              (setq *ID 'edit)
                              (url (ext.html Doc)) ) )
                        (gui '(+Button) "Cancel" '(off *ID)) ) ) )
               ((may Wiki)
                  (<spread>
                     (<this> '*ID 'edit "Edit")
                     (and (: mup) (<this> '*ID 'rpl "Reply")) )
                  (--) ) )
            (cond
               (*MupTxt
                  (pipe (prinl @) (render *MupImg))
                  (off *MupTxt *MupImg) )
               ((: mup)
                  (in (blob @ 'txt) (render (: mup bin)))
                  (<p> NIL
                     (with (: mup)
                        (<tip> "Public URL of this page"
                           (let U (baseHRef *Port1 "?" (: doc nm))
                              (<href> U U) ) )
                        (<spread>
                           #
                           # does anyone use these?
                           #
                           #(<tip> "Download TeX source"
                           #   (<href> "TeX" (pack "!latex?" (ht:Fmt This))) )
                           #(<nbsp> 3)
                           #(<tip> "Download PDF document"
                           #   (<href> "PDF" (pack "!pdf?" (ht:Fmt This))) )
                           #(<nbsp> 3)
                           (prin (datSym (: d)))
                           (<nbsp> 3)
                           (prog
                              (while (: min)
                                 (setq This (: <)) )
                              (<$> (: u nm) (: u)) ) ) )
                     (and *SesId (<$> "Revision History" This)) )
                  (when (: mup rpl)
                     (<hr>)
                     (<h4> NIL "Replies")
                     (recur ()
                        (<ul> NIL
                           (for This (: mup rpl)
                              (<li> NIL
                                 (<href> (nm> (: mup)) (ext.html This))
                                 (<nbsp>)
                                 (ht:Prin (: mup sum))
                                 (and (: mup rpl) (recurse)) ) ) ) ) ) ) ) )
         (clipboardJS)
         (collapsibleJS) ) )
   (off *ID) )

# normal html button
(de <btn> (Attr . Prg)
   (tag 'button Attr 2 Prg) )

# click to copy code blocks
(de clipboardJS ()
   (<javascript>
      "var clipboard = new ClipboardJS('.code', {
         text: function(trigger) {
            return trigger.lastChild.textContent;
         }
      });" ) )

(de collapsibleJS ()
   (<javascript>
     "var coll = document.getElementsByClassName('collapsible');
      var i;
      for (i = 0; i < coll.length; i++) {
         coll[i].addEventListener('click', function() {
            this.classList.toggle('active');
            var content = this.nextElementSibling;
            if (content.style.maxHeight){
               content.style.maxHeight = null;
            } else {
               content.style.maxHeight = content.scrollHeight + 'px';
            }
         });
      }" ) )

# temp holding, don't want to delete this
(de createAccountDialog ()
   (gui '(+Button) "Create Account"
      '(dialog NIL
         (<h4> NIL "Create Account")
         # (<br> "Please supply at least Login Name and EMail Address.")
         (<grid> 2
            "Username*" (gui '(+Focus +Chk +TextField)
               '(let Nm (val> This)
                  (cond
                     ((not Nm) "Please supply a login name")
                     ((db 'nm '+User Nm) "This name is already in use") ) )
               10 )
            "Email*" (gui '(+Chk +TextField)
               '(and
                  *Btn
                  (not (val> This))
                  "Please supply an email address" )
               20 )
            "Full Name" (gui '(+TextField) 20) )
         (<br>)
         (<br> "Clicking \"OK\" will create a new account,")
         (<br> "and send a password to you by email.")
         (<br>)
         (okButton
            '(let Pw (pack (randpw 9))
               (with
                  (new! '(+User)
                     'nm (val> (field -3))
                     'pw (passwd Pw)
                     'role (db 'nm '+Role "Member")
                     'em (val> (field -2))
                     'name (val> (field -1)) )
                  (mail "localhost" 25
                     "noreply@picolisp.com" (: em)
                     "New Account" NIL
                     "A new account on picolisp.com was created for you."
                     NIL
                     (prinl "You can now log in as: " (: nm))
                     (prinl "With the password: " Pw) )
                  (off *ID) ) ) )
         (cancelButton) ) ) )

# Full-text search
(de searchWiki (Words Syms Cnt)
   (<strong> NIL (<br> "Search results:"))
   (if (cdr Syms)
      (when (get Syms 2 '*Dbg -1 (car Syms))
         (<br>
            (<href>
               (pack "SRC: " (car Syms) " " (cdr Syms))
               (pack "!showSource?" (ht:Fmt (car Syms) (cadr Syms))) ) ) )
      (when (; Syms 1 doc)
         (<br>
            (<href>
               (pack "REF: " Syms)
               (pack
                  "https://software-lab.de/"
                  (tail 13 (chop @))  # "doc/refX.html"
                  "#"
                  Syms ) ) ) )
      (when (; Syms 1 *Dbg 1)
         (<br>
            (<href>
               (pack "SRC: " Syms)
               (pack "!showSource?" (ht:Fmt (car Syms))) ) ) ) )
   (let Q
      (goal
         (cons
            (cons
               'select
               '(@@)
               (mapcar
                  '((W) (list 'mup '+Doc W))
                  Words )
               (mapcar
                  '((W)
                     (cons '^
                        (fill
                           '(@ (fetch '(mup . +Doc) (cons W (-> @@))))
                           'W ) ) )
                  Words ) ) ) )
      (loop
         (NIL (prove Q))
         (T (lt0 (dec 'Cnt)) (<br> "(More results)"))
         (with (; @ @@)
            (<br>
               (<href>
                  (or (title> (: mup)) (: nm))
                  (pack "?" (: nm)) ) ) ) ) ) )

(de docFields (Flg)
   (unless *PRG
      (=: mup
         (list
            (and (: obj mup) (in (blob @ 'txt) (till NIL T)))  # txt
            NIL  # sum
            NIL  # min
            (: obj mup bin) ) ) )  # bin
   (gui '(+Var +TextField) (: mup) 80 25)
   (--)
   # BEGIN CHANGES
   (<div> 'flex-row
      (<div> 'flex-col
         (<div> 'flex-row
            (<strong> "Summary") (gui '(+Var +TextField) (: mup -1) 40) ) )
      (<div> 'flex-col
         (<div> 'flex-row
            (gui '(+Var +Checkbox) (: mup -2)) (<span> NIL "This is a minor edit") ) ) )
   (<hr>)
   (gui '(+Var +Chart1) (: mup -3) 3)
   (<div> 'media-grid
      (<table> 'chart NIL '((NIL "Media"))
         (do 3
            (<row> (alternating)
               (gui 1 '(+ObjView +TextField) '(: nm))  # Binary name
               (gui 2 '(+DelRowButton))
               (gui 3 '(+BubbleButton)) ) )
         (<row> NIL (scroll 3 T)) )
      (<div> 'flex-col
         (<div> 'flex-row (<strong> "Specify a name") (gui 'nm '(+TextField) 30) )
         (<div> 'flex-row
            (gui '(+Button) "Fetch from Page"
               '(let Nm (val> (: home nm))
                  (nond
                     (Nm (error "Please specify a name"))
                     ((db 'nm '+Doc (val> (field 1))) (error "Page not found"))
                     ((findBin Nm (; @ mup bin)) (error "Name not found in page"))
                     (NIL (push (: home mup -3) @)) ) ) )
            (gui '(+Val +TextField) fold 30) )
         (<div> 'flex-row
            (gui '(+Drop +Button) '(field 1) "Upload Directly"
               '(nond
                  ((: drop) (error "Please select or drag&drop a file"))
                  ((val> (: home nm)) (error "Please specify a name"))
                  (NIL
                     (blob!
                        (push (: home mup -3) (new! '(+Bin) 'nm @))
                        'd
                        (: drop) ) ) ) )
            (gui '(+UpField) 30) ) ) )
   # END CHANGES
   (<hr>)
   (<spread>
      (gui '(+Rid +Button) "Preview"
         '(setq *MupTxt (: home mup 1)  *MupImg (: home mup 4)) )
      (when Flg
         (gui '(+Button) "Cancel"
            '(prog (rollback) (off *ID)) )
         (saveButton
            '(let Obj (: home obj)
               (when (: home org)  # Reply
                  (dbSync)
                  (put> (: home org mup) 'rpl
                     (append
                        (: home org mup rpl)
                        (cons (setq Obj (new (db: +Doc) '(+Doc)))) ) )
                  (commit 'upd) )
               (apply 'newMup> (: home mup) Obj)
               (off *ID)
               (url (pack (ext.html (or (: home org) Obj)) "?*Menu=+0&*Tab=+2&*ID=$edit")) ) )
         (gui '(+Button) "Save & Close"
            '(let Obj (: home obj)
               (when (: home org)  # Reply
                  (dbSync)
                  (put> (: home org mup) 'rpl
                     (append
                        (: home org mup rpl)
                        (cons (setq Obj (new (db: +Doc) '(+Doc)))) ) )
                  (commit 'upd) )
               (apply 'newMup> (: home mup) Obj)
               (off *ID)
               (url (ext.html (or (: home org) Obj))) ) )
         ) ) )

(de findBin (Nm Lst)
   (setq Nm (fold Nm))
   (find
      '((This) (= Nm (fold (: nm))))
      Lst ) )

(de wikiLink (Lst)
   (let (Nm (pack (car Lst))  Str (or (glue " " (cdr Lst)) (pack (car Lst))))
      (cond
         ((fetch '(nm . +Doc) (fold Nm 0))
            (<href> Str (pack "?" Nm)) )
         (*Login (<this> '*ID Nm Str))
         (T (ht:Prin Str)) ) ) )

(de showSource (Sym Cls)
   (html NIL (pack "PicoLisp Wiki: " (: nm)) *WikiCss NIL
      (when
         (if Cls
            (get Cls '*Dbg -1 Sym)
            (; Sym *Dbg 1) )
         (in (cdr @)
            (do (dec (car @)) (from "\n"))
            (<pre> 'code
               (do 420
                  (prinl (line T))
                  (T (eof)) ) ) ) ) ) )

# vi:et:ts=3:sw=3
