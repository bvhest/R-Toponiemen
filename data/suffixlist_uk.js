/*
** zelf samengestelde lijst van toponiemen, met gebruikmaking van de volgende bronnen:
**   - https://nsaunders.wordpress.com/2019/04/03/mapping-the-vikings-using-r/
**   - https://www.britishmuseum.org/whats_on/exhibitions/vikings/vikings_live/old_norse_origins.aspx
**   - http://www.viking.no/e/heritage/eplacenames.htm
**   - https://www.jorvikvikingcentre.co.uk/the-vikings/viking-place-names/
**
** BHE, 2019-04-12
*/
const suffixList = [
   ["borough"],    // Borg - castle, fortified town 
   ["by"],     //  -by endings are generally places where the Vikings settled first. In Yorkshire there are 210 -by place names. The -by has passed into English as 'by-law' meaning the local law of the town or village.
   ["dale"],    // Dal - valley
   ["ey"],    // Øy - island
   ["fell"],    // Fjell - mountain 
   ["garth"],    // Gård - farm
   ["keld"],    // spring. Example Threkeld
   ["kirk"],    // kirk: originally kirkja, meaning church. Example Ormskirk
   ["ness"],    // Nes - headland, promontory. Note: Sheerness is Old English; Inverness is Gaelic (meaning mouth), Skegness is Old Norse
   ["set"],    // Seter - mountain pasture, shielding. (Summerset). 
   ["sound"],    // Sund - strait(s) 
   ["thwaite"],     // -aarde is een regelmatig gebruikte aanduiding bij een plaatsnaam. Het betekent veld, akker, stuk grond, weide of omheinde plaats.
   ["toft"],    // site of a house or building. Example Lowestoft, Langtoft
   ["ton"],    // -ton is an Anglo-Saxon word meaning town or village
   ["torp", "thorpe"],     // Torp - a secondary settlement - outlying farm. 
   ["voe"],    // Vag - bay
   ["wick"]    // Vik - bay
];