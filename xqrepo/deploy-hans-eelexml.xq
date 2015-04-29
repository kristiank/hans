(:~
 : Adapter module giving structural compatibility with EELex.
 : This module is part of the citizen science project Hans
 : at the Institute of the Estonian Language.
 : copyright 2015 Kristian Kankainen
 :
 : @author Kristian Kankainen
 : @module
 : @version 1.1
 :)
xquery version '3.0';
declare namespace hans = 'http://hans.eki.ee/';
declare namespace vka  = 'http://www.eki.ee/dict/vka';
declare copy-namespaces preserve, inherit;

(:~
 : This imports Hans's relevant files from EELex.
 : Some structural changes are done, therefore the
 : hans:export-to-EELex() method should be used when 
 : appropriate.
 :)
declare updating function hans:import-from-EELex(
)
{
  (: Make a backup of the old db:)
  (: @todo :)
  let $eelex-fp := '/home/kristian/Projektid/EKI/EELex andmebaasid/__shs/__sr/vka/__pildid/'
  let $db := db:open('hans')
  (:~
   : Import the main vka1.xml file
   : the structure is preserved, but associated files are
   : placed in subfolders for each entry.
   :)
  (: @todo db:add('vka1.xml', 'data/vka1.xml':)
  (: change the values of century into simply numerical :)
  for $century in $db//vka:saj
    return replace value of node $century
      with (substring($century, 1, 2))

  (: import the associated files into entry subfolder :)
  ,for $file in $db//vka:ffail
    let $m-id := $file/parent::*:fgrp
                 /preceding-sibling::*:m/data()
    return db:add($eelex:hans-db,
                  concat($eelex-fp, vka:ffail),
                  concat('data/', $m-id, '/', string($file)))
    
};

    db:output('☑ Import from EELex done.'),
    hans:import-from-EELex()

(:~
 : Struktureeri kirjed uues andmebaasis ümber
 :)
(:let $lang := $db//vka:sr/@*:lang
for $article in $db//vka:A
  let $count := $article//vka:m/text()
  return db:add(
    'hans', 
    $article, 
    concat('data/', $count, '.xml')
  )
:)
(: kustutame algse vka1.xml :)
(:,db:delete('hans', 'vka1.xml'):)
(: optimeerime jne :)
(:,db:optimize(
  'ies',
  true(),
  map {
    'ftindex': true(),
    'textindex': true()
  })
:)
