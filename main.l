# 14nov20abu
# (c) Software Lab. Alexander Burger

(allowed ("wiki/" "db/wiki/blob/")
   *PW "!wiki" "!work" "!stop" "@lib.css" #{"!latex" "!pdf"}# "!psh"
   *PRG *Search "!showSource" "!getBlob" "!themeToggle" "!codeToggle" )

(scl 2)
(load
   "@lib/http.l" "@lib/xhtml.l" "@lib/form.l" #{"@lib/tex.l"}# "@lib/adm.l"
   "@lib/boss.l" )

(setq
   *Pool "db/wiki/"
   *Blob "db/wiki/blob/"
   *Jnl (and (info "fifo/wiki") "fifo/wiki")
   *Salt (16 . "$6$@1$")
   *Css
      "@lib.css"
   *WikiCss
      (quote
         "wiki/night-mode.css"
         "wiki/wiki.css" )
   *WikiPort 5000 )

# (allow "wiki/newlib.css")
# (setq *Css "wiki/newlib.css")

(load "wiki/er.l" "wiki/lib.l" "wiki/gui.l")

(push1 '*JS "wiki/js/clipboard.min.js")

(permission
   Wiki        "Edit Wiki Documents"
   System      "Edit System Data"
   Upload      "File upload"
   RoleAdmin   "Role Administration"
   UserAdmin   "User Administration"
   Password    "Password"
   Delete      "Delete" )

(mime "d" NIL 86400)

# Entry point
(de main ()
   (call 'mkdir "-p" *Pool *Blob)
   (pool *Pool *Dbs *Jnl)
   (load "wiki/init.l")
   (unless (db 'nm '+Doc "home")
      (msg "No home document") )
   (if (db 'nm '+Doc "menu")
      (setq *WikiMenu (id @ T))
      (msg "No menu document") ) )

(de go ()
   (rollback)
   (retire 20)
   (gc 4)
   (server (or (format (sys "PORT")) *WikiPort) "!wiki") )

# customizations below

# redefine 'ask' for "modal-style" dialog
# use setq so '# ask redefined' does not clog the logs
(setq ask
   '((Str . Prg)
      (alert (env '(Str Prg))
         (<div> 'modal
            (<div> 'modal-inner
               (<span> 'ask Str)
               (--)
               (yesButton (cons 'prog Prg))
               (noButton) ) ) ) ) )

# (music) repl
(load "wiki/repl.l")
(allow "repl.cropped.svg")

# misc
(on *DisplayDocumentCode)

# cache svgs
# (patch *Mimes '(`(chop "svg") @S) (fill '(`(chop "svg") ^ @S 3600)))

# vi:et:ts=3:sw=3
