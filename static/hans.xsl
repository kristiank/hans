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
                          ' ', $viide/vka:l)"/>
  </xsl:function>

  
  <!-- Genereeri viimaste leidude tabel (NB! XML andmed genereeritakse serveris) -->
  <xsl:template name="show-last-added">
    <!-- laadi viimaste leidude fail sisse -->
    <xsl:variable name="entries" select="doc('../xml/last-added.xml')"/>
    
    <!-- Lisa kuupäev viimati lisatud pealkirja juurde -->
    <xsl:result-document href="#results" method="ixsl:replace-content">
      <xsl:value-of>
        Viimati lisatud 
       <xsl:value-of select="format-date(current-date(), '(seisuga [D].[M].[Y])')"/>
      </xsl:value-of>
    </xsl:result-document>   
  
    <xsl:result-document href="#results" method="replace-content">
      <table>
        <thead><tr><th data-type="date">Kuupäev</th><th>Tekst või kirjeldus</th><th>Allikas</th><th>Teataja</th></tr></thead>
        <tbody>
          <xsl:for-each select="$entries//vka:A">
            <xsl:variable name="date" select="vka:KA"/>
            <xsl:variable name="arakiri-tekst" select="substring(vka:tgrp/vka:arakiri, 1, 150)"/>
            <xsl:variable name="viide" select="vka:agrp/vka:viide"/>
            <xsl:variable name="nimi" select="vka:sgrp/vka:snimi"/>
            <xsl:variable name="id" select="string(.//vka:m)"/>
            <tr data-id="{$id}">
              <td class="date" data-sort-value="{$date}"><div class="date" align="center"><xsl:value-of select="format-date($date, '[D].[M].[Y]')"/></div></td>
              <td class="arakiri-tekst" data-sort-value="{$arakiri-tekst}"><div class="arakiri-tekst"><a href="view?id={$id}"><xsl:value-of select="$arakiri-tekst"/></a></div></td>
              <td class="viide" data-sort-value="{$viide}"><div class="viide"><xsl:value-of select="$viide"/></div></td>
              <td class="nimi" data-sort-value="{$nimi}"><div class="nimi"><xsl:value-of select="$nimi"/></div></td>
            </tr>
          </xsl:for-each>
        </tbody>
      </table>
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