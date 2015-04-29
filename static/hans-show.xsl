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

  <!-- Genereeri ühe leiu info vaade -->
  <xsl:template name="show-info" match="/">
    <xsl:result-document href="#content" method="ixsl:replace-content">
      <xsl:apply-templates select="//vka:A"/>
    </xsl:result-document>
  </xsl:template>
  
  <!-- Infovaate A element (artikkel) -->
  <xsl:template match="vka:A">
    <xsl:result-document href="#content" method="ixsl:append-content">
      <h2>Keeleleid nr #<xsl:value-of select="vka:m"/></h2>
      <div class="vka_A">
        <xsl:if test="not(empty(vka:tgrp/vka:arakiri))"><div class="vka_arakiri"><xsl:value-of select="vka:tgrp/vka:arakiri"/></div></xsl:if>
        <div class="leiu_info_narratiiv">Selle <xsl:value-of select="vka:agrp/vka:dgrp/vka:saj"/>.&#160;sajandi teksti leidis <xsl:value-of select="vka:sgrp/vka:snimi"/> tuhnides üht <xsl:value-of select="vka:agrp/vka:akeel"/>&#173;keelset arhivaari. 
        <xsl:value-of select="substring-before(vka:sgrp/vka:snimi, ' ')"/> registreeris leiu Hansus <xsl:value-of select="format-date(vka:KA, '[D].[M].[Y]')"/>.<br/>
        Leiule võib viidata tekstiliselt „<span class="vka_viide"><xsl:value-of select="hans:vormista-viide(vka:agrp/vka:viide)"/></span>“ või püsi&#173;lingiga „<a href="http://hans.eki.ee/id/{vka:m}">http://hans.eki.ee/id/<xsl:value-of select="vka:m"/></a>“. Loe viitamise kohta rohkem <a>siit</a>.</div>
        <xsl:if test="not(empty(vka:tgrp/vka:kirjeldus))"><div class="vka_kirjeldus">Tekstile on lisatud kirjeldus: <xsl:value-of select="vka:tgrp/vka:kirjeldus"/></div></xsl:if>
        <xsl:if test="not(empty(vka:tgrp/vka:tkom))"><div class="vka_tkom">Teksti ja selle konteksti seletavaid kommentaare: <xsl:value-of select="vka:tgrp/vka:tkom"/></div></xsl:if>
        <xsl:if test="not(empty(.//vka:ffail))"><div class="vka_ffail"><a href="raw/{vka:m}/{.//vka:ffail}">Vaata leiule lisatud pilti.</a></div></xsl:if>
      </div>
    </xsl:result-document>
  </xsl:template>
  
  <!-- Infovaate m element (märksõna) -->
  <xsl:template match="vka:m">
    <xsl:result-document href="#content" method="ixsl:append-content">
      <div class="vka_m">
        Viide <xsl:value-of select="string(.)"/>. leiule
      </div>
      
    </xsl:result-document>
  </xsl:template>

  <!-- Infovaate sgrp element () -->
  <xsl:template match="vka:sgrp">
    <xsl:result-document href="#content" method="ixsl:append-content">
      <div class="vka_sgrp">
        <div class="vka_snimi">
          Tubliks sisestajaks oli <xsl:value-of select="vka:snimi"/>.
        </div>
      </div>
      <xsl:apply-templates/>
    </xsl:result-document>
  </xsl:template>
  
  <!-- Infovaate viite genereerimine -->
  <xsl:template match="vka:agrp">
    <xsl:result-document href="#content" method="ixsl:append-content">
      Arhiiviviide: <xsl:call-template name="vka:viide"/>.
    </xsl:result-document>
  </xsl:template>
  
  <!-- Infovaate sajandi genereerimine -->
  <xsl:template match="vka:viide" name="vka:viide">
    <xsl:result-document href="#content" method="ixsl:append-content">
      <div class="vka_viide"><xsl:value-of select="string(.)"/></div>
    </xsl:result-document>
  </xsl:template>
  
  <!-- Infovaate sajandi genereerimine -->
  <xsl:template match="vka:dgrp">
    <xsl:result-document href="#content" method="ixsl:append-content">
      <xsl:value-of select="string(vka:saj)"/>. sajand.
    </xsl:result-document>
  </xsl:template>
  
  <!-- Infovaate keele genereerimine -->
  <xsl:template match="vka:akeel">
    <xsl:result-document href="#content" method="ixsl:append-content">
      <xsl:value-of select="string(.)"/>ikeelne tekst.
    </xsl:result-document>
  </xsl:template>
  
  <!-- See blokib nende elementide näitamist, millel pole määratud oma template -->
  <xsl:template match="*"/>

</xsl:transform>
