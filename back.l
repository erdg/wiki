# 24feb18abu
# (c) Software Lab. Alexander Burger

(unless (= *PW (pw))
   (quit "back.l" *PW) )

(load "@lib/too.l")
(admin
   (snapshot "/bak/wiki" "db/wiki") )

# vi:et:ts=3:sw=3
