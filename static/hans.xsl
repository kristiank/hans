<xsl:transform
  xmlns:hans="http://hans.eki.ee/"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:ixsl="http://saxonica.com/ns/interactiveXSLT"
  xmlns:prop="http://saxonica.com/ns/html-property"
  xmlns:style="http://saxonica.com/ns/html-style-property"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:vka="http://www.eki.ee/dict/vka"
  xmlns:f="urn:internal.function"
  exclude-result-prefixes="xs prop"
  extension-element-prefixes="ixsl"
  version="2.0"
  >
  <!-- URList saadud argumendid -->
  <xsl:variable name="args" select="f:parse-uri()"/>
  
  <!-- Arhiivide nimetused ja nende käändevorme -->
  <xsl:variable name="arhiivid">
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
      <nimetav>mingi märkimata koht</nimetav>
      <omastav>mingi märkimata koha</omastav>
      <seesütlev>kuskil märkimata kohas</seesütlev>
      <väljaütlev>kuskilt märkimata kohast</väljaütlev>
    </arhiiv>
  </xsl:variable>
  
  <!-- Sõelu URLiga saadud argumendid -->
  <xsl:function name="f:parse-uri">
    <args>
      <xsl:analyze-string regex="([^=&amp;]+)=([^&amp;]*)"
      select="substring(ixsl:get(ixsl:window(), 'location.search'),2)">
        <xsl:matching-substring>
           <xsl:element name="{regex-group(1)}"><xsl:value-of select="regex-group(2)"/></xsl:element>
        </xsl:matching-substring>
      </xsl:analyze-string>
    </args>
  </xsl:function>
  
  <!-- Viite tekstiline vormistamine -->
  <xsl:function name="hans:vormista-viide">
    <xsl:param name="viide" as="element(vka:viide)"/>
    <xsl:sequence select="concat($viide/vka:a,
                          ' ', $viide/vka:f,
                          ' ', $viide/vka:fondinimi,
                          ' ', $viide/vka:n,
                          ' ', $viide/vka:s,
                          ' lk ', $viide/vka:l)"/>
  </xsl:function>

  
  <!-- Genereeri viimaste leidude tabel (NB! XML andmed genereeritakse serveris) -->
  <xsl:template name="show-last-added">
    <!-- laadi viimaste leidude fail sisse -->
    <xsl:variable name="entries" select="doc('../xml/last-added.xml')"/>
    
    <!-- Lisa kuupäev viimati lisatud pealkirja juurde -->
    <xsl:result-document href="#results" method="ixsl:replace-content">
      <h2>Viimati lisatud 
       <xsl:value-of select="format-date(current-date(), '(seisuga [D].[M].[Y])')"/>
      </h2>
    </xsl:result-document>   
  
    <xsl:result-document href="#results" method="replace-content">
      <ul>
        <xsl:for-each select="$entries//vka:A">
          <xsl:variable name="date" select="vka:KA"/>
          <xsl:variable name="arakiri-tekst" select="'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'"/> <!--  select="substring(vka:tgrp/vka:arakiri, 1, 250)"/>  -->
          <xsl:variable name="arhiiv" select="vka:agrp/vka:viide/vka:a"/>
          <xsl:variable name="nimi" select="vka:sgrp/vka:snimi"/>
          <xsl:variable name="eesnimi" select="tokenize(vka:sgrp/vka:snimi, '\s+')[1]"/>
          <xsl:variable name="id" select="string(.//vka:m)"/>
          <xsl:variable name="sajand" select="vka:agrp/vka:dgrp/vka:saj"/>
          <li>
            <div class="lisatud-kirje">
              <span class="vasakul">
                <span class="sajand"><xsl:value-of select="$sajand"/>.</span> sajandi tekst
              </span>
              <span class="keskel">
                <span class="arakiri-tekst"><a href="view?id={$id}"><xsl:value-of select="$arakiri-tekst"/></a></span>
              </span>
              <span class="paremal">
                teksti leidis <xsl:value-of select="$eesnimi"/><xsl:text> </xsl:text><xsl:value-of select="$arhiivid/arhiiv[@nimi = $arhiiv]/väljaütlev"/><xsl:text> </xsl:text><xsl:value-of select="format-date($date, '[D].[M].[Y]')"/>
              </span>
            </div>
          </li>
          <!-- <xsl:if test="position() != last()"><hr/></xsl:if> -->
        </xsl:for-each>
      </ul>
    </xsl:result-document>
  </xsl:template>



  <!-- Ärakirja teksti alguse näitamine (et oleks igal pool ühtlane) -->
  <xsl:function name="hans:ärakiri-algus">
    <xsl:param name="string" as="xs:string"/>
    <xsl:param name="n"      as="xs:integer"/>
    <xsl:param name="sep"    as="xs:string"/>
    
    <xsl:for-each select="tokenize($string, $sep)">
    	<xsl:if test="position() &lt; $n">
    	  <xsl:value-of select="."/>
    	  <xsl:text> </xsl:text>
    	</xsl:if>
    </xsl:for-each>
  </xsl:function>




  <!-- Järjesta tabeli veerud kui nendele klikitakse -->
  <xsl:template match="th" mode="ixsl:onclick">
    <xsl:variable name="colNr" as="xs:integer"  select="count(preceding-sibling::th)+1"/>  
    <xsl:apply-templates select="ancestor::table[1]" mode="sort">
      <xsl:with-param name="colNr" select="$colNr"/>
      <xsl:with-param name="dataType" select="if (@data-type='number') then 'number' else 'text'"/>
      <xsl:with-param name="ascending" select="not(../../@data-order=$colNr)"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <!-- Tabeliveergude järjestaja -->
  <xsl:template match="table" mode="sort">
    <xsl:param name="colNr"     as="xs:integer" required="yes"/>
    <xsl:param name="dataType"  as="xs:string" required="yes"/>
    <xsl:param name="ascending" as="xs:boolean" required="yes"/>
    <xsl:result-document href="?select=." method="ixsl:replace-content">
      <thead data-order="{if ($ascending) then $colNr else -$colNr}">
        <xsl:copy-of select="thead/tr"/>
      </thead>
      <tbody>
        <xsl:perform-sort select="tbody/tr">
          <xsl:sort select="td[$colNr]/@data-sort-value" 
            data-type="{$dataType}" 
            order="{if ($ascending) then 'ascending' else 'descending'}"/>
        </xsl:perform-sort>
      </tbody>
    </xsl:result-document>
  </xsl:template>
  
  <!-- Tabelipäiste kohtspikri kuvamine kui hiir tuleb peale -->
  <xsl:template match="th" mode="ixsl:onmouseover">
    <xsl:for-each select="//div[@id='sortToolTip']">
        <ixsl:set-attribute name="style:left" select="concat(ixsl:get(ixsl:event(), 'clientX') + 30, 'px')"/>
        <ixsl:set-attribute name="style:top"  select="concat(ixsl:get(ixsl:event(), 'clientY') - 15, 'px')"/>
        <ixsl:set-attribute name="style:visibility" select="'visible'"/>
    </xsl:for-each>
  </xsl:template>
  
  <!-- Tabelipäiste kohtspikri peitmine kui hiir läheb pealt ära -->
  <xsl:template match="th" mode="ixsl:onmouseout">
    <xsl:for-each select="//div[@id='sortToolTip']">
        <ixsl:set-attribute name="style:visibility" select="'hidden'"/>
    </xsl:for-each>
  </xsl:template>


</xsl:transform>