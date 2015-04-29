(:~
 : This module is part of the crowdsourced project ""Hans" at
 : the Institute of the Estonian Language.
 :
 : @author Kristian Kankainen, EKI 2015, GNU GPLv3 License
 : @link http://hans.eki.ee/
 :)

xquery version "3.0" encoding "UTF-8";
module namespace hans = "http://hans.eki.ee/";
declare namespace vka = "http://www.eki.ee/dict/vka";
declare default element namespace "http://www.eki.ee/dict/vka";

import module namespace rest = "http://exquery.org/ns/restxq";
import module namespace request = "http://exquery.org/ns/request";

(:~
 : Returns the WADL information of the server's services
 :)
declare
  %rest:GET
  %rest:path("hans/wadl")
  %output:method("xml")
function hans:wadl-info-xml()
{
  let $wadl-info := rest:wadl()
  return $wadl-info
};
(: /hans/viide/ $viide-uri :)
(: /hans/allikas/ $allikas-osa :)
(: /hans/sajand/ $algus $lõpp :)
(:~
 : Kiirotsing otsib kõiki välju, v.a sisestaja andmeid
 :)
declare
  %rest:GET
  %rest:path("hans/otsing/{$text}")
function hans:otsing-kiir-xml( $text as xs:string )
{
  <vka:sr>{
    if (not(string-length($text) > 0))
    then ()
    else
      let $results := db:open("hans", "/vka1.xml")/vka:sr 
        //(vka:agrp|vka:tgrp|vka:fgrp|vka:lgrp|vka:KOM)[fn:matches(., $text)]
        //parent::*:A
      for $result in $results
      return
        <vka:A>{
          $result//vka:A/@*}{ (: copy attributes :)
          (: filter some child elements :)
          for $child in $result/(* except (vka:sgrp | vka:G | vka:K | vka:T))
          return
            $child
        }</vka:A>
  }</vka:sr>
};
(: //(*:agrp|*:tgrp|*:fgrp|*:lgrp|*:KOM)[contains(., "nin")]//parent::*:A :)
(: /hans/otsing/sisestaja/ $nimi :)
(: /hans/otsing/kommentaar/ $sisu-osa :)
(: /hans/otsing/kirjeldus/ $sisu-osa :)
(:~
 : Tagastab kõik ärakirjad mis sisaldavad otsitud teksti
 : @param text the text to search
 : @param n the number of results returned
 :)
declare
  %rest:GET
  %rest:path("hans/otsing/arakiri")
  %rest:query-param("text", "{$text}", "")
  %rest:query-param("n", "{$n}", "15")
function hans:otsing-arakiri-xml(
  $text as xs:string,
  $n as xs:positiveInteger )
{
  let $n := if ($n < 1) then 15 else $n
  let $text := $text
  return
    <vka:sr>{
      if (not(string-length($text) > 0))
      then ()
      else
        db:open("hans", "/vka1.xml")/vka:sr
        /vka:A/vka:tgrp/vka:arakiri[contains(., $text)]
        /parent::*/parent::vka:A[position() = (last() - $n to last())]
    }</vka:sr>
};
(: /hans/otsing/arakiri/ $sisu-osa :)
(: /hans/otsing/sisestatud/ $kuupaev :)
(:~
 : Returns an entry by it's ID
 : @param $id the ID
 :)
declare
  %rest:GET
  %rest:path("hans/otsing/id")
  %rest:query-param("id", "{$id}", "0")
  %output:method("xml")
function hans:otsing-id-xml( $id as xs:positiveInteger)
{
  let $db := db:open("hans", "/vka1.xml")
  return 
    <a:sr xmlns:a="nome">{
      if ($id = 0)
      then "Puudub ID number!"
      else $db/vka:sr/vka:A/vka:m[. = $id]
      /parent::vka:A
    }</a:sr>
};
(: /hans/otsing/id/ $id :)
(: /hans/toimeta/id/ $id :)
(:~
 : Returns the last n entries
 : NB! expects the xml structure to be chronologically structured
 : @param n the number of entries, default is 15
 :)
declare
  %rest:GET
  %rest:path("hans/xml/viimati-lisatud.xml")
  %rest:query-param("n", "{$n}", "15")
function hans:last-n-entries-xml( $n as xs:positiveInteger)
{
  let $n := $n - 1
  return
    <vka:sr>{
      db:open("hans", "/vka1.xml")/vka:sr
      /vka:A[position() = (last() - $n to last())]
    }</vka:sr>
};

(:~
 : hans/vaata/id  shows an entry in the db
 : hans/muuda/id  lets alter an entry in the db
 : hans/uus       lets insert a new entry in the db
 : eelex/hans/get-next-id
 :)

(:~
 : Shows an entry from the db
 :)
declare
  %rest:path("hans/vaata")
  %rest:GET
  %rest:query-param("id", "{$id}", 0)
function hans:vaata(
  $id as xs:integer
)
{
  if ($id = 0)
  then <alert>Puudub kirje number!</alert>
  else <a>{$id}</a>
    (:let $db := db:open("hans", "/vka1.xml") :)
    
      (:<a:sr xmlns:a="nome">{
        $db/vka:sr/vka:A/vka:m[. = $id]
        /parent::vka:A
      }</a:sr>:)
};

(:~
 : Simple data echo service for testing HTML form posting
 :)
declare
  %rest:path("hans/echo")
  %rest:POST("{$data}")
  (:%rest:consumes("multipart/form-data"):)
(:  %rest:header-param("User-Agent", "{$agent}"):)
function hans:echo(
    $data (:as item()*:)
) as element(response)
{
  (: the picture files will be saved in ./__pildid/ $m_number :)
  <response type="form">
    <count>{ count($data) }</count>
    <message>{ $data }</message>
    <elements>{
      for $el in request:parameter-names()
      return element param {$el, request:parameter($el)}
      
    }</elements>
  </response>
};

(:~
 : Filters private and sensitive element from the A elements
 :)
 
 

(: Trying server-side XSLTforms transformation :)
declare
  %rest:path("hans/xforms")
  %rest:GET
  (:%output:method("html"):)
function hans:xforms() {
  
  let $page := <html xmlns="http://www.w3.org/1999/xhtml" xmlns:xf="http://www.w3.org/2002/xforms">
   <head>
      <title>Hello World in XForms</title>
      <xf:model>
         <xf:instance>
            <data xmlns="">
               <PersonGivenName/>
            </data>
         </xf:instance>
      </xf:model>
   </head>
   <body>
      <p>Type your first name in the input box.
        If you are running XForms, the output should be displayed in the output area.</p>   
       <xf:input ref="PersonGivenName" incremental="true">
          <xf:label>Please enter your first name: </xf:label>
       </xf:input>
       
       <xf:output value="concat('Hello ', PersonGivenName, '. We hope you like XForms!')">
          <xf:label>Output: </xf:label>
       </xf:output>
   </body>
</html>

let $static-page := "static/hans-xforms.xml"

return xslt:transform-text($static-page, 
                           'static/xsltforms/xsltforms.xsl', 
                           map { "baseuri": "../static/xsltforms/" })(:,
                                 "xsltforms_lang": "et", (: @todo get lang from agent :)
                                 "xsltforms_debug": "yes" })
:)

};