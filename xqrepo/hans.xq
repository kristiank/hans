(:~
 : This module is part of the citizen science project "Hans" at
 : the Institute of the Estonian Language.
 : 
 : Copyright EKI 2015, GNU GPLv3 License
 : 
 : @author Kristian Kankainen
 : @link http://hans.eki.ee/
 : @version 1.0
 :)

xquery version "3.0" encoding "UTF-8";
module  namespace eelex = "http://eelex.eki.ee/";
declare namespace hans  = "http://hans.eki.ee/";
declare namespace vka   = "http://www.eki.ee/dict/vka";
declare namespace xf    = "http://www.w3.org/2002/xforms";

(:~
 : This module has identity problems and behaves both as an 
 : EELex module and an Adapter pattern for a Hans-to-EELex module.
 : Therefore there are some global variables as for now.
:)
declare variable $eelex:hans-db   := "hans";
declare variable $eelex:hans-path := "vka1.xml";
declare variable $eelex:hans-ns   := "http://www.eki.ee/dict/vka";

(: Estonian is morphologically rich ... :)
declare variable $eelex:arhiivid  := <data>
    <arhiiv nimi="EAA">
      <nimetav>Eesti Ajalooarhiiv</nimetav>
      <omastav>Eesti Ajalooarhiivi</omastav>
      <seesütlev>Eesti Ajalooarhiivis</seesütlev>
      <väljaütlev>Eesti Ajalooarhiivist</väljaütlev>
    </arhiiv>
    <arhiiv nimi="AM">
      <nimetav>Eesti Ajaloomuuseum</nimetav>
      <omastav>Eesti Ajaloomuuseumi</omastav>
      <seesütlev>Eesti Ajaloomuuseumis</seesütlev>
      <väljaütlev>Eesti Ajaloomuuseumist</väljaütlev>
    </arhiiv>
    <arhiiv nimi="EKLA">
      <nimetav>Eesti Kultuurilooline Arhiiv</nimetav>
      <omastav>Eesti Kultuuriloolise Arhiivi</omastav>
      <seesütlev>Eesti Kultuuriloolises Arhiivis</seesütlev>
      <väljaütlev>Eesti Kultuuriloolisest Arhiivist</väljaütlev>
    </arhiiv>
    <arhiiv nimi="LVVA">
      <nimetav>Läti Riiklik Ajalooarhiiv</nimetav>
      <omastav>Läti Riikliku Ajalooarhiivi</omastav>
      <seesütlev>Läti Riiklikus Ajalooarhiivis</seesütlev>
      <väljaütlev>Läti Riiklikust Ajalooarhiivist</väljaütlev>
    </arhiiv>
    <arhiiv nimi="SRA">
      <nimetav>Rootsi Riigiarhiiv</nimetav>
      <omastav>Rootsi Riigiarhiivi</omastav>
      <seesütlev>Rootsi Riigiarhiivis</seesütlev>
      <väljaütlev>Rootsi Riigiarhiivist</väljaütlev>
    </arhiiv>
    <arhiiv nimi="TLA">
      <nimetav>Tallinna Linnaarhiiv</nimetav>
      <omastav>Tallinna Linnaarhiivi</omastav>
      <seesütlev>Tallinna Linnaarhiivis</seesütlev>
      <väljaütlev>Tallinna Linnaarhiivist</väljaütlev>
    </arhiiv>
    <arhiiv nimi="muu">
      <nimetav>kuskil</nimetav>
      <omastav>mingi</omastav>
      <seesütlev>kuskil</seesütlev>
      <väljaütlev>kuskilt</väljaütlev>
    </arhiiv>
</data>;


(:~
 : Internal function giving an id for a new database entry.
 :
 : @since 1.0
 : @param $db The name of the db
 : @param $path The path in the db
 : @return xs:positiveInteger The next available id as an xs:positiveInteger
 :)
declare
function eelex:get-next-id(
  $db as xs:string,
  $path
) as xs:positiveInteger
{
  let $highest-id := max(db:open($db, $path)
                         /*:sr/*:A/*:m/@*:O)
  let $new-id     := $highest-id + 1
  return xs:positiveInteger($new-id)
};



(:~
 : Internal function for specifying an entry's id number. The id number
 : must be larger than 0.
 :
 : @param $entry The element that will be id numbered
 : @param $new-id The id number
 : @return element() The $entry with an id number element added
 :)
declare
function eelex:specify-id(
  $entry as element(),
  $new-id as xs:integer
) as element()
{
  let $new-id := xs:positiveInteger($new-id)
  return
    copy $new-entry := $entry
    modify(
      delete node $new-entry/*:m, (: @todo preserve if present! :)
      insert node (<vka:m vka:O="{$new-id}">{$new-id}</vka:m>)
        as first into $new-entry
    )
    return $new-entry
};


(:~
 : Convenince function for saving and updating entries.
 : If no $entry-id is given a new entry will be created. Otherwise
 : the specified entry will be updated with the content given.
 : 
 : @todo this could be considered an Adapter pattern and thus
 : not part of the eelex module, instead a part of the hans module.
 : 
 : @since 1.0
 : @param $content The content to be saved
 : @param $entry-id Optional entry id, if not given, a new entry will be created
 : @return (:@todo:)
 :)
declare
updating function eelex:save(
  $content as element(),
  $entry-id as xs:integer?
) (: as @todo:)
{
  if(not(exists($entry-id)) or $entry-id = 0)
  then eelex:save-new-entry($content)
  else eelex:update-entry($entry-id, $content)
};



(:~
 : Creates a new entry with the specified content.
 : 
 : @todo this could be considered an Adapter pattern and thus
 : not part of the eelex module, instead a part of the hans module.
 : This is why the code uses global variables.
 : 
 : @since 1.0
 : @param $content The content to be saved
 : @return (:@todo:)
 :)
declare
  %rest:path("save-new")
  %rest:POST("{$data}")
updating function eelex:save-new-entry(
  $data as document-node()
) (:as @todo:)
{
  let $input-doc := $data//vka:A
  let $new-id := eelex:get-next-id($eelex:hans-db, $eelex:hans-path)
  let $db := db:open($eelex:hans-db, $eelex:hans-path)/vka:sr
  (: add current datetime marking the creation :)
  let $with-date := eelex:add-creation-datetime($input-doc)
  (: add an id number :)
  let $with-id := eelex:specify-id($with-date, $new-id)
  let $final-entry := $with-id
  (:@todo check schema conformity:)
  return
    (db:output('Salvestatud!'),
    insert node $final-entry
      as last into $db
    )
};



(:~
 : Updates the specified entry with elements from a given entry
 : entries left out in the new entry will thus be left untouched
 : 
 : @todo this could be considered an Adapter pattern and thus
 : not part of the eelex module, instead a part of the hans module.
 : This is why the code uses global variables.
 : 
 : @since 1.0
 : @param $content The content to be saved
 : @return (:@todo:)
 :)
declare
updating function eelex:update-entry(
  $entry-id as xs:integer,
  $input-doc as element(vka:A)
) (:as @todo:)
{
  (: @todo check if entry exists! :)
  let $old-entry := db:open($eelex:hans-db, $eelex:hans-path)/vka:sr
      /vka:A[vka:m/@vka:O = $entry-id]
  
  return 
    replace node $old-entry
      with copy $updated-entry := $old-entry
      modify (
        for $element in $input-doc/(* except (*:m, *:sgrp, *:G, *:K, *:KA, *:TA))
          return
            if($element instance of element())
            then(
              if($updated-entry/*[node-name(.) = node-name($element)])
              then(replace node $updated-entry/*[node-name(.) = node-name($element)]
                   with ($element))
              else(insert node $element into $updated-entry)
            )
            else(),
        (: insert a datetime stamp for the edit :)
        insert node (element {QName($eelex:hans-ns, "vka:TA")} {current-dateTime()})
          into $updated-entry
      )
      (: @todo check consistency :)
      return $updated-entry
};


(:~
 : Web service for saving an updated entry in the database.
 :
 : @since: 1.0
 : @param $data The POSTed data
 :)
declare
  %rest:path("update-entry")
  %rest:POST("{$data}")
updating function eelex:web-update-entry(
  $data (: as document-node() :)
)
{
  let $id := xs:positiveInteger($data//vka:m)
  let $new-entry := $data//vka:A
  let $old-entry := eelex:get-by-id($id)/vka:A
  
  return
    (: @todo check if email is the same :)
    if(not($old-entry//vka:skontakt = $new-entry//vka:skontakt))
    then(db:output('vale epostiaadress'))
    else((db:output('Toimetatud!'),
     eelex:update-entry($id, $new-entry)))
};

(:~
 : Adds the creation date element "KA" with current dateTime.
 :
 : @since 1.0
 : @param $input-doc The root element (e.g *:sr/*:A)
 : @return element() The $input-doc with added date element
 :)
declare
function eelex:add-creation-datetime(
  $input-doc as element()
) as element()
{
  let $element := QName($eelex:hans-ns, "vka:KA")
  let $datetime := current-dateTime()
  return eelex:add-datetime-element($input-doc, $element, $datetime)
};



(:~
 : Adds a last edited date element "TA" with current dateTime.
 :
 : @since 1.0
 : @param $input-doc The root element (e.g *:sr/*:A)
 : @param $datetime The datetime value as xs:dateTime
 : @return element() The $input-doc with added date element
 :)
declare
function eelex:add-edit-datetime(
  $input-doc as element()
) as element()
{
  let $element := QName($eelex:hans-ns, "vka:TA")
  let $datetime := current-dateTime()
  return eelex:add-datetime-element($input-doc, $element, $datetime)
};



(:~
 : Adds an element with the specified element name holding the date.
 :
 : @since 1.0
 : @param $input-doc The root element (e.g *:sr/*:A)
 : @param $element-name The name of the element holding the dateTime
 : @param $datetime The datetime value as xs:dateTime
 : @return element() The $input-doc with added date element
 :)
declare
function eelex:add-datetime-element(
  $input-doc as element(),
  $element,
  $datetime as xs:dateTime
) as element()
{
  let $datetime-element := element {$element} {$datetime}
  return
    copy $new-entry := $input-doc
    modify(
      insert node $datetime-element
        into $new-entry
    )
    return $new-entry
};



(:~
 : Deletes an entry with specified id.
 :
 : @since 1.0
 : @param $id The id of the entry to be deleted
 :)
declare
updating function eelex:delete-with-id(
  $id as xs:integer
)
{
  delete node db:open($eelex:hans-db, $eelex:hans-path)//vka:A[*:m = $id]
};



(:~
 : Web interface for searching.
 :
 : @since 1.0
 : @param q An optional query for landing from outside
 : @return HTML
 :)
declare
  %rest:GET
  %rest:path("search")
  %rest:query-param("q", "{$q}", "")
  %output:method('html')
function eelex:web-search(
  $q as xs:string
)
{
  let $content := <content>
                    <h2>Otsing</h2>
                    <form action="search">
                    <input type="text" name="q" id="search-box"
                     title="Otsing" label="Otsing" autocomplete="off"
                     autofocus="yes"/>
                    <input type="submit" name="submit" value="otsi kohe"/>
                    </form>
                  </content>
  let $page := 
    copy $template := fetch:xml(concat(file:base-dir(),
                                'hans-template.html'))
    modify(
      replace value of node $template/html/head/title
        with ("HANS otsing «" || $q || "» (" || current-date() || " seisuga)"),
      insert node (attribute {"src"} {"static/hans-search.xsl"})
        into $template//script[@language="xslt2.0"],
      insert node (attribute {"data-initial-template"} {"show-search-results"})
        into $template//script[@language="xslt2.0"],
      insert node $content into $template//*:div[@id = 'content']
    ) return $template
  
  return $page
};




(:~
 : Paginated search function. Uses the eelex:search function for searching.
 :
 : @since 1.0
 : @param $q The search string
 : @param $num-results The number of results per page
 : @param $page The number of the page to show (default is 1)
 :)
declare
  %rest:path("xml/search")
  %rest:GET
  %rest:query-param("q", "{$q}", "")
  %rest:query-param("results", "{$num-results}", "20")
  %rest:query-param("page", "{$page}", "1")
function eelex:paginated-search(
  $q as xs:string,
  $num-results as xs:integer,
  $page as xs:integer
) as element()
{
  let $stop :=  (($page - 1) * $num-results) + $num-results
  let $start :=  (($page - 1) * $num-results) + 1
  
  let $results := eelex:simple-search($q)(:($start to $stop):)
  return
    <vka:search-results
      found="{count($results)}"
      q="{$q}">{
      $results
    }</vka:search-results>
  (: @todo this does not propagate the limitation to the search :)
};



(:~
 : Internal search function. The eelex:paginated-search functions should
 : be used instead of directly invoking this function.
 :
 : The returned search results are filtered for privacy reasons.
 :
 : @since 1.0
 : @param $q The search string
 :)
declare
function eelex:simple-search(
  $q as xs:string
) as element(vka:A)*
{
  if (not(string-length($q) > 0))
  then ()
  else
    let $results := db:open($eelex:hans-db, $eelex:hans-path)/vka:sr
      //(vka:agrp|vka:tgrp|vka:fgrp|vka:lgrp|vka:KOM)[fn:matches(., $q)]
      //parent::*:A
    for $result in $results
    return
      eelex:privatize-xml($result)
};



(:~
 : Simple data echo service for testing HTML form posting
 :
 : @deprecated
 : @since 1.0
 : @param POST data
 :)
declare
  %rest:path("echo")
  %rest:POST("{$data}")
  (:%rest:consumes("multipart/form-data"):)
(:  %rest:header-param("User-Agent", "{$agent}"):)
function eelex:echo(
    $data
) as element(response)
{
  <response type="echo">
    <count>{ count($data) }</count>
    <message>{ $data }</message>
  </response>
};


(:~
 : Web user interface using XForms for saving new entries.
 :
 : @since 1.0
 :)
declare
  %rest:GET
  %rest:path("new")
  %output:method("xml")
function eelex:web-save-xforms(
)
{
  fetch:xml(
    concat(file:base-dir(), 'web-save-xforms.xml'))
};


(:~
 : Web user interface using XForms for showing and updating
 : old entries.
 :
 : @since 1.0
 : @param id The id of the entry
 :)
declare
  %rest:GET
  %rest:path("edit")
  %rest:query-param("id", "{$id}", "0")
  %output:method("xml")
function eelex:web-update-xforms(
  $id as xs:integer
)
{
  if(not($id > 0))
  then(<hans:error>
         <message>Leiu id number puudub</message>
       </hans:error>)
  else
    copy $page := fetch:xml(
      concat(file:base-dir(), 'web-update-xforms.xml'))
    modify (
      insert node attribute {'src'} {
        (: the URL for the entry's xml :)
        web:create-url("xml", map {"id": $id})
      }
        into $page//xf:instance[@id = "hans-instance"]
    ) return $page
};



(:~
 : Internal function for retrieving an entry by it's id.
 :
 : @since 1.0
 :)
declare
function eelex:get-by-id(
  $id as xs:integer
)
{
  let $entry := db:open($eelex:hans-db, $eelex:hans-path)
      /vka:sr/vka:A/vka:m[. = $id]
      /parent::vka:A
  return
    <vka:sr>{
      if(empty($entry))
      then <vka:A/>
      else $entry
    }</vka:sr>
};



(:~
 : Web service returning the entry specified by it's id.
 :
 : @since 1.0
 : @param id The id of the entry
 : @return XML
 :)
declare
  %rest:GET
  %rest:path("xml")
  %rest:query-param("id", "{$id}", "0")
  %output:method("xml")
  %output:omit-xml-declaration("no")
  %output:normalization-form("NFC")
function eelex:web-get-by-id(
  $id as xs:integer
)
{
  eelex:privatize-xml(eelex:get-by-id($id))
};



(:~
 : Web service returning the last added entries.
 : The number of entries can optionally be specified with parameter n.
 :
 : @since 1.0
 : @param n Optional number of entries to show
 : @return XML
 :)
declare
  %rest:GET
  %rest:path("xml/last-added.xml")
  %rest:query-param("n", "{$n}", "7")
  %output:method("xml")
  %output:omit-xml-declaration("no")
  %output:indent("yes")
  %output:normalization-form("NFC")
function eelex:web-last-added(
  $n as xs:integer
)
{
  let $entries := db:open($eelex:hans-db, $eelex:hans-path)
                  //vka:A[position() = (last() - $n to last())]
  return
    <vka:sr>{
      for $entry in $entries
        return eelex:privatize-xml($entry)
    }</vka:sr>
};



(:~
 : Web interface showing an entry's details in a narrative tone.
 :
 : @since 1.0
 : @param id The id of the entry
 : @return HTML
 :)
declare
  %rest:GET
  %rest:path("view")
  %rest:query-param("id", "{$id}", "0")
  %output:method('html')
function eelex:web-view-narrative(
  $id as xs:integer
)
{
  let $content := ('')
  let $page := 
    copy $template := fetch:xml(concat(file:base-dir(),
                                'hans-template.html'))
    modify(
      replace value of node $template/html/head/title
        with ("HANS leid " || $id),
      insert node (attribute {"src"} {"static/hans-show.xsl"})
        into $template//script[@language="xslt2.0"],
      insert node (attribute {"data-initial-template"} {"show-info-narrative"})
        into $template//script[@language="xslt2.0"],
      insert node (attribute {"data-source"} {"xml?id=" || $id})
        into $template//script[@language="xslt2.0"],
      insert node $content into $template//*:div[@id = 'content']
    ) return $template
  
  return $page
};



(:~
 : Web interface showing an entry's details in a detailed tone.
 :
 : @since 1.1
 : @param id The id of the entry
 : @return HTML
 :)
declare
  %rest:GET
  %rest:path("view-detailed")
  %rest:query-param("id", "{$id}", "0")
  %output:method('html')
function eelex:web-view-detailed(
  $id as xs:integer
)
{
  let $content := ('')
  let $page := 
    copy $template := fetch:xml(concat(file:base-dir(),
                                'hans-template.html'))
    modify(
      replace value of node $template/html/head/title
        with ("HANS leid " || $id),
      insert node (attribute {"src"} {"static/hans-show.xsl"})
        into $template//script[@language="xslt2.0"],
      insert node (attribute {"data-initial-template"} {"show-info-detailed"})
        into $template//script[@language="xslt2.0"],
      insert node (attribute {"data-source"} {"xml?id=" || $id})
        into $template//script[@language="xslt2.0"],
      insert node $content into $template//*:div[@id = 'content']
    ) return $template
  
  return $page
};



(:~
 : Internal function for privatizing entries before publishing them as XML online.
 :
 : @since 1.0
 : @return XML
 :)
declare
function eelex:privatize-xml(
  $entry as element()
)
{
  copy $filtered := $entry
  modify(
    delete node $filtered//vka:G,
    delete node $filtered//vka:K,
    delete node $filtered//vka:T,
    replace value of node $filtered//vka:skontakt with '',
    delete node $filtered//vka:slink
  )
  return $filtered
};



(:~
 : First page of the portal
 :)
declare
  %rest:GET
  %rest:path("")
  %output:method('html')
function eelex:web-start-page()
{
  let $content := fetch:xml(concat(file:base-dir(), 'web-index.xml'))
  let $page := 
    copy $template := fetch:xml(concat(file:base-dir(),
                                'hans-template.html'))
    modify(
      replace value of node $template/html/head/title
        with ("HANS avaleht "),
      insert node (attribute {"src"} {"static/hans.xsl"})
        into $template//script[@language="xslt2.0"],
      insert node (attribute {"data-initial-template"} {"show-last-added"})
        into $template//script[@language="xslt2.0"],
      insert node (attribute {"data-source"} {"xml/last-added.xml"})
        into $template//script[@language="xslt2.0"],
      insert node $content/content/* into $template//*:div[@id = 'content']
    ) return $template
  
  return $page
};



(:~
 : RSS News feed version of the last added entries.
 :
 : @since 1.0
 : @return RSS
 :)
declare
  %rest:GET
  %rest:path("newsfeed/rss.xml")
  %output:method("xml")
  %output:omit-xml-declaration("no")
  %output:indent("yes")
  %output:normalization-form("NFC")
function eelex:rss-last-added(
)
{
  let $entries := eelex:web-last-added(20)//vka:A
  return
    <rss version="2.0">
    <channel>
      <title>HANS Eesti keel kirjalikes ajaloo­allikates</title>
      <link>http://hans.eki.ee/</link>
      <description>HANS on ühis­loome töö­vahend eesti keele vanemate (13.—18. sajandi) kirja­panekute kogumiseks ja uurimiseks.</description>
      <language>et</language>
      <generator>BaseX</generator>
      <managingEditor>kristian@eki.ee</managingEditor>
      <webMaster>kristian@eki.ee</webMaster>
      {
      for $entry in $entries
        let $link := 'http://hans.eki.ee/view?id=' || string($entry//vka:m)
        return
          <item>
            <title>Põnev tekst {string($entry//vka:saj)}.&#160;sajandist leiti {$eelex:arhiivid/arhiiv[@nimi = $entry//vka:a]/väljaütlev/data()}</title>
            <link>{$link}</link>
            <guid>{$link}</guid>
            <pubDate>
              {format-dateTime(xs:dateTime($entry//vka:KA),
                '[FNn,*-3], [D01] [MNn,*-3] [Y0001] [H01]:[m01]:[s01] GMT')}
            </pubDate>
            <description>Teksti leidis {tokenize($entry//snimi)[1]} tuhnides {string($entry//vka:akeel)}&#173;keelset ürikut {$eelex:arhiivid/arhiiv[@nimi = $entry//vka:a]/seesütlev/data()}. <a href="{$link}">Vaata lähemalt leiu lehelt</a>.</description>
          </item>
      }
      </channel>
    </rss>
};



(:~
 : Adapter module giving structural compatibility with EELex.
 :
 : This imports Hans's relevant files from EELex.
 : Some structural changes are done, therefore the
 : eelex:export-to-EELex() method should be used when
 : appropriate.
 : 
 : @since 1.1
 : @param $eelex-dir The EELex directory
 :)
declare updating function eelex:import-from-EELex(
  $eelex-dir as xs:string)
{
  let $db := db:open($eelex:hans-db, $eelex:hans-path)
  (: The database file needs to be cleaned before importing :)
  let $new-db := 
    copy $eelex-db := doc(concat($eelex-dir, 'vka1.xml'))
    modify(
       (: normalize the values of century into simply numerical :)
      for $century in $eelex-db//vka:saj
        return replace value of node $century
          with substring($century, 1, 2)
      (: normalize old text substitutions :)
      ,for $text in $eelex-db//vka:tgrp/(vka:arakiri|vka:kirjeldus|vka:tkom)
        (: let $norm-text1 := replace($text, "&#xA;", '') :)
        (: let $norm-text2 := replace($norm-text1, "&#xD;", '') :)
        let $norm-text := replace($text, "&amp;br;", out:nl())
        let $new-text := 
          element {node-name($text)} {
            for $line in tokenize($norm-text, "[\n\r]+")
              return element {'p'} {$line}
          }
        return replace node $text
          with $new-text
    )
    return $eelex-db
  
  return (
    (: Make a backup of the old db:)
    db:create-backup($eelex:hans-db)

    (: Import the previously modified version of the vka1.xml file :)
    ,db:replace($eelex:hans-db,
               'vka1.xml',
               $new-db)
    
    (: Import the associated files into entry subfolder :)
    ,for $file in $new-db//vka:ffail
      let $m-id := $file/parent::*:fgrp
                     /preceding-sibling::*:m/data()
      return
        db:store($eelex:hans-db,
                 concat('data/', $m-id, '/', $file/data()),
                 file:read-binary(
                   concat($eelex-dir, '__pildid/', $file/data())))
  )
};



(:~
 : Simple web interface for reading stored binary files (pictures).
 :
 : @since 1.1
 : @param $id The entry id
 : @param $fp The file path
 :)
declare
  %rest:GET
  %rest:path("raw/{$id}/{$fp}")
  %output:method("raw")
function eelex:web-get-raw-file(
  $id as xs:integer,
  $fp as xs:string
)
{
  stream:materialize(
    db:retrieve($eelex:hans-db,
                concat('data/', $id, '/', $fp)))
};