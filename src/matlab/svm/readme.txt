Tanítás:
	inputfolder megadása, amiben alfolderek vannak (foldernév - címke, tartalom predictorok)

Ha 'validify' értéke igaz, akkor felosztódik minden alfolder 2 részre: tanító és validáló halmazra,
ahol a validáló halmaz 0.7, míg a tanító 0.3-ad része az eredeti képhalmaznak.

Visszatérési érték egy osztályozó objektum betanítva, ezt a következõ script használja fel.

példa hívás: trainSimpleSingleSVM([],[], true) // default képhalmaz+elérési út (ha használjátok,
ÍRJÁTOK FELÜL), saját vagy gyári feature extractor fgv (itt default a SURF), validify true - validálás aktív //

Tesztelés:
	a predikciót adó script egy képobjektumot vár (read-el olvasva) vagy egy elérési utat (õ maga olvassa be)
jelenleg még csak egyenként lehet odaadni neki képeket