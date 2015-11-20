//--------------------
SimpleSingleSVM fgv-ek:

Tanítás:
	inputfolder megadása, amiben alfolderek vannak (foldernév - címke, tartalom predictorok)

Ha 'validify' értéke igaz, akkor felosztódik minden alfolder 2 részre: tanító és validáló halmazra,
ahol a validáló halmaz 0.7, míg a tanító 0.3-ad része az eredeti képhalmaznak.

Visszatérési érték egy osztályozó objektum betanítva, ezt a következõ script használja fel.

példa hívás: trainSimpleSingleSVM([],[], true, [])
// default képhalmaz+elérési út (ha használjátok,
// ÍRJÁTOK FELÜL), saját vagy gyári feature extractor fgv (itt default a SURF), validify true - validálás aktív,
// wordNumber - üres, akkor default = 64

Tesztelés:
	a predikciót adó script egy képobjektumot vár (read-el olvasva) vagy egy elérési utat (õ maga olvassa be)
jelenleg még csak egyenként lehet odaadni neki képeket

példa hívás: classifySingleSimpleSVM('D:\imgpath\img.jpg', classifier)
// string file+path
// elõzõ fgv által visszaadott osztályozó objektum

//--------------------
ECOCSVM fgv-ek:

Tanítás:
	Ugyanaz, mint a SimpleSingleSVM-nél, csak itt plusz egy output van: a felépített BagOfWords objektum, mely
	ahhoz kell, hogy tesztelésnél elõ lehessen állítani a jellemzõvektort az eredeti képbõl.

Tesztelés:
	Ugyanaz, mint a SimpleSingleSVM-nél, csak kell a BagOfWords objektum.
	(kisebb hiba, hogy még nem jó az ImageSet-es dolog, úgyhogy ezt még javítanom kell, ne használjátok ezt a fgv-t)

//--------------------
