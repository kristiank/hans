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
      <nimetav>Eesti Ajaloo&#173;arhiiv</nimetav>
      <omastav>Eesti Ajaloo&#173;arhiivi</omastav>
      <seesütlev>Eesti Ajaloo&#173;arhiivis</seesütlev>
      <väljaütlev>Eesti Ajaloo&#173;arhiivist</väljaütlev>
    </arhiiv>
    <arhiiv nimi="AM">
      <nimetav>Eesti Ajaloo&#173;muuseum</nimetav>
      <omastav>Eesti Ajaloo&#173;muuseumi</omastav>
      <seesütlev>Eesti Ajaloo&#173;muuseumis</seesütlev>
      <väljaütlev>Eesti Ajaloo&#173;muuseumist</väljaütlev>
    </arhiiv>
    <arhiiv nimi="EKLA">
      <nimetav>Eesti Kultuuri&#173;looline Arhiiv</nimetav>
      <omastav>Eesti Kultuuri&#173;loolise Arhiivi</omastav>
      <seesütlev>Eesti Kultuuri&#173;loolises Arhiivis</seesütlev>
      <väljaütlev>Eesti Kultuuri&#173;loolisest Arhiivist</väljaütlev>
    </arhiiv>
    <arhiiv nimi="LVVA">
      <nimetav>Läti Riiklik Ajaloo&#173;arhiiv</nimetav>
      <omastav>Läti Riikliku Ajaloo&#173;arhiivi</omastav>
      <seesütlev>Läti Riiklikus Ajaloo&#173;arhiivis</seesütlev>
      <väljaütlev>Läti Riiklikust Ajaloo&#173;arhiivist</väljaütlev>
    </arhiiv>
    <arhiiv nimi="SRA">
      <nimetav>Rootsi Riigi&#173;arhiiv</nimetav>
      <omastav>Rootsi Riigi&#173;arhiivi</omastav>
      <seesütlev>Rootsi Riigi&#173;arhiivis</seesütlev>
      <väljaütlev>Rootsi Riigi&#173;arhiivist</väljaütlev>
    </arhiiv>
    <arhiiv nimi="TLA">
      <nimetav>Tallinna Linna&#173;arhiiv</nimetav>
      <omastav>Tallinna Linna&#173;arhiivi</omastav>
      <seesütlev>Tallinna Linna&#173;arhiivis</seesütlev>
      <väljaütlev>Tallinna Linna&#173;arhiivist</väljaütlev>
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
    <xsl:sequence select="normalize-space(concat($viide/vka:a,
                          ' ', $viide/vka:f,
                          ' ', $viide/vka:fondinimi,
                          ' ', $viide/vka:n,
                          ' ', $viide/vka:s,
                          ' ', $viide/vka:l))"/>
  </xsl:function>

  
  <!-- Genereeri viimaste leidude tabel (NB! XML andmed genereeritakse serveris) -->
  <xsl:template name="show-last-added">
    <!-- laadi viimaste leidude fail sisse -->
    <xsl:variable name="entries" select="doc('../xml/last-added.xml')"/>
    
    <!-- Lisa kuupäev viimati lisatud pealkirja juurde -->
    <xsl:result-document href="#results" method="ixsl:replace-content">
      <h2>Viimati lisatud tekstid
       <!-- <xsl:value-of select="format-date(current-date(), '(seisuga [D].[M].[Y])')"/> -->
      </h2>
    </xsl:result-document>   
  
    <xsl:result-document href="#results" method="replace-content">
      <ul>
        <xsl:for-each select="$entries//vka:A">
          <xsl:sort select="xs:date(vka:KA)" order="descending"/>
          <xsl:variable name="current-date" select="current-date()"/>
          <xsl:variable name="date-added" select="xs:date(vka:KA)"/>
          <xsl:variable name="duration" select="$current-date - $date-added"/>
          <xsl:variable name="days-ago" select="days-from-duration($duration)"/>
          <xsl:variable name="months-ago" select="months-from-duration($duration)"/>
          <xsl:variable name="date">
            <xsl:choose>
              <xsl:when test="$months-ago gt 0 and $months-ago lt 12">
                <xsl:value-of select="concat($months-ago, ' kuu eest')"/>
              </xsl:when>
              <xsl:when test="$days-ago lt 1">
                <xsl:value-of select="'lausa täna'"/>
              </xsl:when>
              <xsl:when test="$days-ago lt 14">
                <xsl:value-of select="concat($days-ago, ' päeva eest')"/>
              </xsl:when>
              <xsl:when test="$days-ago lt (2 * 14)">
                <xsl:value-of select="concat(floor($days-ago div 7), ' nädala eest')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="'rohkem kui aasta aega tagasi'"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="arakiri-tekst">
            <xsl:choose>
              <xsl:when test="string-length(vka:tgrp/vka:arakiri) gt 150">
                 <xsl:value-of select="concat(substring(vka:tgrp/vka:arakiri, 1, 150), '…')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="vka:tgrp/vka:arakiri"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
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
                <span class="arakiri-tekst"><a class="nolink" href="view?id={$id}"><xsl:value-of select="$arakiri-tekst"/></a></span>
              </span>
              <span class="paremal">
                Teksti leidis <xsl:value-of select="$eesnimi"/><xsl:text> </xsl:text><xsl:value-of select="$date"/><xsl:text> </xsl:text><xsl:value-of select="$arhiivid/arhiiv[@nimi = $arhiiv]/väljaütlev"/>
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