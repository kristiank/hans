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
  <xsl:import href="hans.xsl"/>
  
  <!-- Otsinguvastete tabeli genereerija -->

  <xsl:template name="show-search-results">
    <!-- laadi viimaste leidude fail sisse -->
    <xsl:variable name="entries" select="doc(concat('../xml/search?q=', string($args/q)))"/>
    <xsl:variable name="q" select="$entries/vka:search-results/@q"/>
    <xsl:variable name="entries-count" select="$entries/vka:search-results/@found"/>
    <xsl:variable name="is-plural" select="not($entries-count = 1)"/>
    
    <!-- Lisa otsingu ja leitud vastete kirjeldus -->
    <xsl:result-document href="#results" method="ixsl:replace-content">
      Leiti 
      <xsl:choose>
        <xsl:when test="$is-plural"><xsl:value-of select="$entries-count"/> vastet</xsl:when>
        <xsl:otherwise>üks vaste</xsl:otherwise>
      </xsl:choose> 
      päringule «<xsl:value-of select="$q"/>» 
     <xsl:value-of select="format-date(current-date(), '(seisuga [D].[M].[Y])')"/>
    </xsl:result-document>   
    
    <!-- Lisa otsingu vastete tabel -->
    <xsl:result-document href="#results" method="replace-content">
      <table>
        <thead><tr><th data-type="date">Kuupäev</th><th>Tekst või kirjeldus</th><th>Allikas</th><th>Teataja</th></tr></thead>
        <tbody>
          <xsl:for-each select="$entries//vka:A">
            <xsl:variable name="date" select="vka:KA"/>
            <xsl:variable name="arakiri-tekst" select="replace(substring(vka:tgrp/vka:arakiri, 1, 150),'(&lt;p&gt;|&lt;/p&gt;)+', '')"/>
            <xsl:variable name="viide" select="vka:agrp/vka:viide"/>
            <xsl:variable name="nimi" select="vka:sgrp/vka:snimi"/>
            <xsl:variable name="id" select="string(.//vka:m)"/>
            <xsl:variable name="uri" select="concat('show?id=', .//vka:m)"/>
            <tr data-uri="{$uri}">
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

</xsl:transform>