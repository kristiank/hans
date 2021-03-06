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

  <!-- Genereeri ühe leiu narratiivne vaade -->
  <xsl:template name="show-info-narrative" match="/">
    <xsl:result-document href="#content" method="ixsl:replace-content">
      <xsl:apply-templates select="//vka:A" mode="narrative"/>
    </xsl:result-document>
  </xsl:template>
  
  <!-- Genereeri ühe leiu üksikasjalik vaade -->
  <xsl:template name="show-info-detailed" match="/">
    <xsl:result-document href="#content" method="ixsl:replace-content">
      <xsl:apply-templates select="//vka:A" mode="detailed"/>
    </xsl:result-document>
  </xsl:template>
  
  <!-- Artikli narratiivne vaade -->
  <xsl:template match="vka:A" mode="narrative">
    <xsl:variable name="arhiiv" select="vka:agrp/vka:viide/vka:a"/>
    <xsl:variable name="id" select="vka:m"/>
    <xsl:result-document href="#content" method="ixsl:append-content">
      <h2>Keeleleid nr <xsl:value-of select="$id"/></h2>
        <xsl:if test="not(empty(vka:tgrp/vka:arakiri))"><div class="vanatekst"><xsl:sequence select="vka:tgrp/vka:arakiri/p"/></div></xsl:if>
        <div class="metainfonarratiiv"><p>Selle <xsl:value-of select="vka:agrp/vka:dgrp/vka:saj"/>.&#160;sajandil kirja pandud teksti leidis <xsl:value-of select="vka:sgrp/vka:snimi"/> tuhnides <xsl:if test="vka:agrp/vka:akeel != 'eesti'"> üht muidu <xsl:value-of select="vka:agrp/vka:akeel"/>&#173;keelset ürikut </xsl:if> <xsl:value-of select="$arhiivid/arhiiv[@nimi = $arhiiv]/seesütlev"/>. Täpsemini on ta sellele viidanud kui „<span class="viide"><xsl:value-of select="hans:vormista-viide(vka:agrp/vka:viide)"/></span>“.
        <xsl:value-of select="tokenize(vka:sgrp/vka:snimi, '\s+')[1]"/> registreeris leiu Hansus <xsl:value-of select="format-date(vka:KA, '[D].[M].[Y]')"/>.
        Leiule võib viidata kirje id-numbriga <xsl:value-of select="vka:m"/> või püsi&#173;lingiga <a href="http://hans.eki.ee/id/{vka:m}">http://hans.eki.ee/id/<xsl:value-of select="vka:m"/></a>. Leidudele viitamise kohta võid lugeda rohkem <a href="citing">siit</a>.</p></div>
        <xsl:if test="not(empty(vka:tgrp/vka:kirjeldus))">
          <div class="lisainfo"><h2>Tekstile on lisatud kirjeldus</h2><xsl:sequence select="vka:tgrp/vka:kirjeldus/p"/></div>
        </xsl:if>
        <xsl:if test="not(empty(vka:tgrp/vka:tkom))"><div class="lisainfo"><h2>Teksti ja selle tausta on seletatud kommentaariga</h2><xsl:sequence select="vka:tgrp/vka:tkom/p"/></div></xsl:if>
        <xsl:if test="not(empty(.//vka:ffail))">
          <div class="pisipildid"><h2>Leiule on lisatud <xsl:choose><xsl:when test="count(.//vka:ffail) gt 1">pildid</xsl:when><xsl:otherwise>pilt</xsl:otherwise></xsl:choose></h2>
            <xsl:for-each select=".//vka:ffail">
              <a href="raw/{$id}/{.}"><img class="pisipilt" alt="Leidu kirjeldav pilt" src="raw/{$id}/{.}"/></a>
            </xsl:for-each>
          </div>
          </xsl:if>
        <div class="toiminguriba">
        <h2>Tegevused ja orienteerumine</h2>
          <p><a href="edit?id={vka:m}">Toimeta leiu andmeid</a>. <a href="view-detailed?id={vka:m}">Vaata täpsemaid andmeid</a>. <a href="xml?id={vka:m}">Vaata andmete XMLi</a>.</p>
        </div>
        <div class="orienteerumisriba"><p><a href="#">Avasta sama ajastu tekste</a>. <a href="#">Avasta samast arhiivist leitud tekste</a>.</p></div>
    </xsl:result-document>
  </xsl:template>
  
  
  
  <!-- Artikli üksikasjalik vaade -->
  <xsl:template match="vka:A" mode="detailed">
    <xsl:result-document href="#content" method="ixsl:append-content">
      <h2>Keeleleid nr #<xsl:value-of select="vka:m"/></h2>
      <table>
        <thead><tr><th>Väli</th><th>Väärtus</th></tr></thead>
        <tbody>
          <tr><td>m</td><td><xsl:value-of select="//vka:m"/></td></tr>
          <tr><td>snimi</td><td><xsl:value-of select="//vka:snimi"/></td></tr>
          <tr><td>arakiri</td><td><xsl:value-of select="//vka:arakiri"/></td></tr>
          <tr><td>kirjeldus</td><td><xsl:value-of select="//vka:kirjeldus"/></td></tr>
          <tr><td>tkom</td><td><xsl:value-of select="//vka:tkom"/></td></tr>
          <tr><td>a</td><td><xsl:value-of select="//vka:a"/></td></tr>
          <tr><td>f</td><td><xsl:value-of select="//vka:f"/></td></tr>
          <tr><td>fondinimi</td><td><xsl:value-of select="//vka:fondinimi"/></td></tr>
          <tr><td>n</td><td><xsl:value-of select="//vka:n"/></td></tr>
          <tr><td>s</td><td><xsl:value-of select="//vka:s"/></td></tr>
          <tr><td>l</td><td><xsl:value-of select="//vka:l"/></td></tr>
          <tr><td>saj</td><td><xsl:value-of select="//vka:saj"/></td></tr>
          <tr><td>akeel</td><td><xsl:value-of select="//vka:akeel"/></td></tr>
          <tr><td>kn</td><td><xsl:value-of select="//vka:kn"/></td></tr>
          <tr><td>ffail</td><td><xsl:for-each select="//vka:ffail"><xsl:value-of select="."/><xsl:text>; </xsl:text></xsl:for-each></td></tr>
          <tr><td>link</td><td><xsl:for-each select="//vka:link"><xsl:value-of select="."/><xsl:text>; </xsl:text></xsl:for-each></td></tr>
          <tr><td>KA</td><td><xsl:value-of select="//vka:snimi"/></td></tr>
          <tr><td>TA</td><td><xsl:for-each select="//vka:TA"><xsl:value-of select="."/><xsl:text>; </xsl:text></xsl:for-each></td></tr>
        </tbody>
      </table>
    </xsl:result-document>
  </xsl:template>


</xsl:transform>
