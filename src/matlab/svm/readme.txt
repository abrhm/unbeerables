Tan�t�s:
	inputfolder megad�sa, amiben alfolderek vannak (foldern�v - c�mke, tartalom predictorok)

Ha 'validify' �rt�ke igaz, akkor feloszt�dik minden alfolder 2 r�szre: tan�t� �s valid�l� halmazra,
ahol a valid�l� halmaz 0.7, m�g a tan�t� 0.3-ad r�sze az eredeti k�phalmaznak.

Visszat�r�si �rt�k egy oszt�lyoz� objektum betan�tva, ezt a k�vetkez� script haszn�lja fel.

p�lda h�v�s: trainSimpleSingleSVM([],[], true) // default k�phalmaz+el�r�si �t (ha haszn�lj�tok,
�RJ�TOK FEL�L), saj�t vagy gy�ri feature extractor fgv (itt default a SURF), validify true - valid�l�s akt�v //

Tesztel�s:
	a predikci�t ad� script egy k�pobjektumot v�r (read-el olvasva) vagy egy el�r�si utat (� maga olvassa be)
jelenleg m�g csak egyenk�nt lehet odaadni neki k�peket