/*
** zelf samengestelde lijst van toponiemen, met gebruikmaking van de volgende bronnen:
**   - toponiem (wikipedia) : https://nl.wikipedia.org/wiki/Toponiem
**   - Plaatsnamen. Plaatsen, steden, dorpen en hun betekenis : http://www.volkoomen.nl/Plaatsnamen%20en%20hun%20betekenis.htm
**
** BHE, 2016-01-06
*/
const suffixList = [
   ["aarde"], // -aarde is een regelmatig gebruikte aanduiding bij een plaatsnaam. Het betekent veld, akker, stuk grond, weide of omheinde plaats.
   ["akker"], // Het woord akker komt van het Latijnse "ager". Het Latijnse woord voor landbouwer is "agricola" een samenstelling van "ager(akker) en "colo" (bebouwen/bewerken).
   ["beek"],
   ["berg"],
//   ["bork"],
   ["bos", "bosch"], 
   ["broek", "brand"], // Germaans: Een broek is een laaggelegen gebied dat nat blijft door opwellend grondwater (kwel) of is een langs een rivier of beek gelegen laag stuk land dat regelmatig overstroomt en 's winters vaak langere tijd onder water staat. Een brand is een toponiem dat voorkomt in verband met moerassige plaatsen en draslanden.
   ["brug"],
   ["burg", "borg", "steyn", "stein"], // Germaans: nederzettingen rond de burchten of forten uit de feodale tijd leidden tot namen op -burg
   ["cum"], // Gallo-Romeins: De uitgang '(i)acum' of '(i)anum' (bezit): Villariacum, Blariacum (Blerick), Viroviacum (Wervik),Cortoriacum (Kortrijk), Orola(u)num (Aarlen).
   ["daal", "dael", "dal", "del", "delle"], // -Daal in plaatsnamen duidt op "beschutte plaats".
   /* Een dam is een dwars door een water gelegen afsluiting, bedoeld om water te keren of te beheersen. Een dergelijke dam is vaak een bruikbare oversteekplaats. 
      Veel nederzettingen in het waterrijke Nederland zijn bij zo'n oversteekplaats ontstaan en ontlenen er hun naam aan. 
   */
   ["dam", "damme", "dammen"],
   ["deel"],
   ["dijk", "dijke"],
   ["donk"], // De benaming donk, of woerd wordt in verschillende regio's gebruikt voor een heuvel die zich duidelijk aftekent tegenover een lager gelegen gebied, en bij alle typen heel vaak een bewoonde plek.
   ["doorn"], // afgeleid van het Germaanse woord durnum, dat doorn betekende (meervoud durnu-).
   ["dorp", "dorpe"],
   ["drecht", "dracht", "tricht", "trecht"], // doorwaadbare plaats in een rivier
   ["driel"],
   ["ede", "de", "da"],
   ["eind", "ende"],
   ["ga"],
//   ["gem"], // Germaans: betekent gem zoveel als 'huis van'.
   ["gent"], // monding van rivier
   ["haag", "hage"], 
   ["heem", "hem", "heim", "chem"], // Germaans: afkomstig van het Germaanse woord haima, dat woning betekende.
   ["horst", "host", "ost", "hurst"], // Germaans: afkomstig van het Germaanse woord hursti, dat beboste opduiking in moerassig terrein[1] betekende.
   ["hoorn", "horn"], // verwijst doorgaans naar de geografische ligging of gesteldheid van die plaats. Bijvoorbeeld dat die plaats is gelegen op een in het water uitstekend stuk land of dat een dijk daar ter plaatse een scherpe hoek heeft.
   ["hoven", "hove", "hof"],
   ["hout", "holt"], // afkomstig van het Germaanse woord hulta dat bos of hout betekent.[1] Het gaat bij holt dan ook om een specifiek soort bos, namelijk een bos dat gebruikt wordt voor leveren van timmerhout (bosbouw).
   ["huizen", "huisen", "huis", "buurt"],
   ["hurk"], // Hurk is een toponiem dat vooral voorkomt in Noord-Brabant. De betekenis gaat in beide gevallen terug op het middelnederlandse Hoornink wat "spits" of "hoek" betekent of letterlijk: "Iets hoorn-vormigs".
   ["ing", "ingen", "ung", "ungen", "ens"],
   ["karspel", "kerspel", "kerspil", "carspel", "carspil"], // middelnederlandse benaming voor een kerkgemeente, een parochie of een onderdeel daarvan.
   ["kerk", "kerke", "kerken", "klooster", "parochie"],
//   ["leie"], // Keltisch voor waterloop
   ["loo", "lo", "los", "le"], // Germaans: woord lauha(z) (open plek in een bos; bosje op hoge zandgrond) is in heel veel plaatsnamen terug te vinden als loo of le.
   ["made", "mede", "maat", "meet", "miede"], // een stuk grasland dat meestal als hooiland gebruikt wordt.
//   ["mark"], // Mark is in het Oudnederlands marka en het Middelnederlands ma(e)rke, merke en betekent dan grens.
   ["meer"],
   ["molen"],
   ["muiden", "muide"],
   ["rijk", "rick", "vik"],
   ["rode", "rhode", "rooi", "rooie", "roede", "rade", "ray"], // Germaans: rotha, betekent oorspronkelijk grond waar bos is "gerooid", open plek, vrijgemaakt in woeste heide- of bosgebieden. 
   ["schoten", "schote", "schoot"], // Germaans: mogelijk afgeleid van het Germaans: skauta-, wat een 'beboste hoek hoger land uitspringend in moerassig terrein' betekende.
   ["sel", "ster", "lee"], // Gallo-Romeins: bijv. Castellum (fort): Kassel, Kessel, Castra (legerplaats): Kester, Kasterlee, Chastre, Kesteren, Kaaster, Kaster
   ["sluis"], 
   ["speet"], // -speet is vermoedelijk afgeleid van spade. Spade en spitten verwijst naar de ontginning van woeste gronden.
   ["terp", "werf", "werve"], // een Fries woord waarmee in Nederland kunstmatige heuvels worden aangeduid, die werden opgeworpen om bij hoogwater een droge plek te hebben. -werf of -werve (Duits: Warft) verwijst naar een terp (opgeworpen hoogte).
   ["til", "tille"], // Een til of tille is een Oudfriese naam voor een (meestal vaste) brug.
//   ["foort", "vorden", "voerde", "forde", "fort", "vort", "voirt", "furt"], 
   ["veen"],
   ["veer"],
   ["veld"],
   ["vliet"], // Vliet is Oudnederlands voor een watergang.
   ["voorde", "voord", "voort", "voirt", ], // // voorde (Middelnederlands: vort of vorda), drecht (in Friesland en soms in West-Friesland ook dracht genoemd), trecht of tricht is een doorwaadbare plaats, meestal in een beek of rivier.
   ["waard", "weerd"], // Een waard (of weerd) is een oude naam voor een vlak landschap in een rivierengebied.
   ["weg"],
   ["wierde", "werd", "warden", "wier", "warf", "werf", "weer"],
   ["wijk"], // Gallo-Romeins: bijv. Vicus (dorp, gehucht, wijk): Katwijk, Opwijk, Noorderwijk, Oisterwijk, Oudwijk, Wijk bij Duurstede, Vicq
   ["wold", "wolde", "woud", "woude"], // afgeleid van het Oudnederlandse woord walt, Middelnederlands wout, wat 'uitgestrekt, ongeëxploiteerd bos'[1] of 'zompig bos inzonderheid in het zeekleigebied'[2] betekent.
   ["zand", "zande"],
   ["zaal", "selle", "zele", "sale"], // Germaans: sel(e) verwijst naar het Oudgermaanse sala (verwant aan het Nederlands zaal): een gebouw, woning, zaalgebouw, nederzetting of beschutting. 
   ["zee"],
   ["zijl", "zeel", "zeil", "ziel"] // Zijl is in Noord-Nederland het woord voor spuisluis.
];