xquery version "3.0" encoding "UTF-8";
declare namespace hans = "http://hans.eki.ee/";
declare namespace x = "http://www.eki.ee/dict/vka";
declare namespace vka = "http://www.eki.ee/dict/vka";

import module namespace eelex = 'http://eelex.eki.ee/' at 'hans.xq';

declare variable $hans:hans-db   := "Hans-vka1";
declare variable $hans:hans-path := "vka1.xml";

(:
let $id := eelex:get-next-id($hans:hans-db, $hans:hans-path)
return $id
:)
(:
file:list('/home/kristian/Projektid/EKI/EELex andmebaasid/__shs/__sr/vka/')
:)
eelex:import-from-EELex()


(:
let $vana := db:open($hans:hans-db, $hans:hans-path)/vka:sr/vka:A[position() = 10]
let $uus := $vana

return eelex:delete-with-id(25)
return eelex:save($uus, ())
eelex:save(<x:A proov="2">ei muuda <vau>uudne kuupäev</vau>
<veel>selline</veel></x:A>, 22)
:)

(:
eelex:specify-id(<pole><x:m O="4">siin</x:m> pole</pole>, 3)
:)

(: Kustutab kõik proovid ära :)
(:
delete node //*:A[exists(@proov)]
:)

(: Kustutab kindla numbriga proovi ära:)
(:
delete node //*:A[exists(@proov) and *:m/@*:O=23]
:)