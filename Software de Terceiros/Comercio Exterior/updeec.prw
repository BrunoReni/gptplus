#Include 'Protheus.ch'
#Include "Average.ch"
#Include "TOPCONN.CH"

/*/{Protheus.doc} UPD_EEC
      Função para atualização de tabelas do módulo SIGAEEC

   @type  Function
   @author bruno kubagawa
   @since 31/05/2023
   @version version
   @param cRelease, caractere, release do sistema
   @return nenhum
   @example
   (examples)
   @see (links_or_references)
/*/
function UPD_EEC( cRelease )
   local oUpd       := nil
   local cRelFinish := ""

   default cRelease := GetRPORelease()

   cRelFinish := SubSTR(cRelease,Rat(".",cRelease)+1)

   oUpd := AVUpdate01():New()
   oUpd:lSimula := .F.
   oUpd:aChamados := {}
   aAdd(oUpd:aChamados,  {nModulo, {|o| cargaELO(o)}} )
   aAdd(oUpd:aChamados,  {nModulo, {|o| cargaEVN(o)}} ) 
   aAdd(oUpd:aChamados,  {nModulo, {|o| EDadosEEA(o)}} )
   oUpd:cTitulo := "Update para o modulo carga padrão da tabela EEA."

   if existfunc("ELinkDados")
      aAdd(oUpd:aChamados,  {nModulo, {|o| ELinkDados(o)}} )
      oUpd:cTitulo := "Carga inicial das tabelas utilizadas na integração com os módulos financeiro e contábil."
   endif

   aAdd(oUpd:aChamados,  {nModulo, {|o| cargaEC6(o)}} )
   oUpd:cTitulo := "Verifica a carga inicial da tabela EC6 quando a mesma estiver exclusiva no sistema"

   aAdd(oUpd:aChamados,  {nModulo, {|o| EEDadosEJ0(o)}} )
   aAdd(oUpd:aChamados,  {nModulo, {|o| CargEC6Adt(o)}} )

   oUpd:Init(,.T.) 

   if cRelFinish > "027" .and. EEA->(ColumnPos("EEA_TIPMOD")) > 0
      AtuDoc()
      AtuModeloAPH()
   endif

return nil

static function cargaELO(o)

   if AvFlags("DU-E") .And. !ELO->(DBSeek(xFilial("ELO") + PadR("AD", len(ELO->ELO_COD))))

      o:TableStruct("ELO",{"ELO_COD" ,"ELO_DESC"  },1)
      o:TableData( 'ELO',{ 'AD','ANDORRA'})
      o:TableData( 'ELO',{ 'AE','UNITED ARAB EMIRATES'})
      o:TableData( 'ELO',{ 'AF','AFGHANISTAN'})
      o:TableData( 'ELO',{ 'AG','ANTIGA AND BARBUDA'})
      o:TableData( 'ELO',{ 'AI','ANGUILLA'})
      o:TableData( 'ELO',{ 'AL','ALBANIA'})
      o:TableData( 'ELO',{ 'AM','ARMENIA'})
      o:TableData( 'ELO',{ 'AN','NETHERLANDS ANTILLES'})
      o:TableData( 'ELO',{ 'AO','ANGOLA'})
      o:TableData( 'ELO',{ 'AQ','ANTARCTICA'})
      o:TableData( 'ELO',{ 'AR','ARGENTINA'})
      o:TableData( 'ELO',{ 'AS','AMERICAN SAMOA'})
      o:TableData( 'ELO',{ 'AT','AUSTRIA'})
      o:TableData( 'ELO',{ 'AU','AUSTRALIA'})
      o:TableData( 'ELO',{ 'AW','ARUBA'})
      o:TableData( 'ELO',{ 'AX','ÅLAND ISLANDS'})
      o:TableData( 'ELO',{ 'AZ','AZERBAIJAN'})
      o:TableData( 'ELO',{ 'BA','BOSNIA AND HERZEGOVINA'})
      o:TableData( 'ELO',{ 'BB','BARBADOS'})
      o:TableData( 'ELO',{ 'BD','BANGLADESH'})
      o:TableData( 'ELO',{ 'BE','BELGIUM'})
      o:TableData( 'ELO',{ 'BF','BURKINA FASO'})
      o:TableData( 'ELO',{ 'BG','BULGARIA'})
      o:TableData( 'ELO',{ 'BH','BAHRAIN'})
      o:TableData( 'ELO',{ 'BI','BURUNDI'})
      o:TableData( 'ELO',{ 'BJ','BENIN'})
      o:TableData( 'ELO',{ 'BL','SAINT BARTH'})
      o:TableData( 'ELO',{ 'BM','BERMUDA'})
      o:TableData( 'ELO',{ 'BN','BRUNEI DARUSSALAM'})
      o:TableData( 'ELO',{ 'BO','BOLIVIA'})
      o:TableData( 'ELO',{ 'BQ','BONAIRE, SINT EUSTATIUS AND SABA'})
      o:TableData( 'ELO',{ 'BR','BRAZIL'})
      o:TableData( 'ELO',{ 'BS','BAHAMAS'})
      o:TableData( 'ELO',{ 'BT','BHUTAN'})
      o:TableData( 'ELO',{ 'BV','BOUVET ISLAND'})
      o:TableData( 'ELO',{ 'BW','BOTSWANA'})
      o:TableData( 'ELO',{ 'BY','BELARUS'})
      o:TableData( 'ELO',{ 'BZ','BELIZE'})
      o:TableData( 'ELO',{ 'CA','CANADA'})
      o:TableData( 'ELO',{ 'CC','COCOS {KEELING) ISLANDS'})
      o:TableData( 'ELO',{ 'CD','CONGO, THE DEMOCRATIC REPUBLIC OF THE'})
      o:TableData( 'ELO',{ 'CF','CENTRAL AFRICAN REPUBLIC'})
      o:TableData( 'ELO',{ 'CG','CONGO'})
      o:TableData( 'ELO',{ 'CH','SWITZERLAND'})
      o:TableData( 'ELO',{ 'CI',"CÈTE D'IVOIRE"})
      o:TableData( 'ELO',{ 'CK','COOK ISLANDS'})
      o:TableData( 'ELO',{ 'CL','CHILE'})
      o:TableData( 'ELO',{ 'CM','CAMEROON'})
      o:TableData( 'ELO',{ 'CN','CHINA'})
      o:TableData( 'ELO',{ 'CO','COLOMBIA'})
      o:TableData( 'ELO',{ 'CR','COSTA RICA'})
      o:TableData( 'ELO',{ 'CS','SERBIA AND MONTENEGRO'})
      o:TableData( 'ELO',{ 'CU','CUBA'})
      o:TableData( 'ELO',{ 'CV','CAPE VERDE'})
      o:TableData( 'ELO',{ 'CX','CHRISTMAS ISLAND'})
      o:TableData( 'ELO',{ 'CW','CURAÇAO'})
      o:TableData( 'ELO',{ 'CY','CYPRUS'})
      o:TableData( 'ELO',{ 'CZ','CZECH REPUBLIC'})
      o:TableData( 'ELO',{ 'DE','GERMANY'})
      o:TableData( 'ELO',{ 'DJ','DJIBOUTI'})
      o:TableData( 'ELO',{ 'DK','DENMARK'})
      o:TableData( 'ELO',{ 'DM','DOMINICA'})
      o:TableData( 'ELO',{ 'DO','DOMINICAN REPUBLIC'})
      o:TableData( 'ELO',{ 'DZ','ALGERIA'})
      o:TableData( 'ELO',{ 'EC','ECUADOR'})
      o:TableData( 'ELO',{ 'EE','ESTONIA'})
      o:TableData( 'ELO',{ 'EG','EGYPT'})
      o:TableData( 'ELO',{ 'EH','WESTERN SAHARA'})
      o:TableData( 'ELO',{ 'ER','ERITREA'})
      o:TableData( 'ELO',{ 'ES','SPAIN'})
      o:TableData( 'ELO',{ 'ET','ETHIOPIA'})
      o:TableData( 'ELO',{ 'FI','FINLAND'})
      o:TableData( 'ELO',{ 'FJ','FIJI'})
      o:TableData( 'ELO',{ 'FK','FALKLAND ISLANDS {MALVINAS)'})
      o:TableData( 'ELO',{ 'FM','MICRONESIA, FEDERATED STATES OF'})
      o:TableData( 'ELO',{ 'FO','FAROE ISLANDS'})
      o:TableData( 'ELO',{ 'FR','FRANCE'})
      o:TableData( 'ELO',{ 'GA','GABON'})
      o:TableData( 'ELO',{ 'GB','UNITED KINGDOM'})
      o:TableData( 'ELO',{ 'GD','GRENADA'})
      o:TableData( 'ELO',{ 'GE','GEORGIA'})
      o:TableData( 'ELO',{ 'GF','FRENCH GUIANA'})
      o:TableData( 'ELO',{ 'GG','GUERNSEY'})
      o:TableData( 'ELO',{ 'GH','GHANA'})
      o:TableData( 'ELO',{ 'GI','GIBRALTAR'})
      o:TableData( 'ELO',{ 'GL','GREENLAND'})
      o:TableData( 'ELO',{ 'GM','GAMBIA'})
      o:TableData( 'ELO',{ 'GN','GUINEA'})
      o:TableData( 'ELO',{ 'GP','GUADELOUPE'})
      o:TableData( 'ELO',{ 'GQ','EQUATORIAL GUINEA'})
      o:TableData( 'ELO',{ 'GR','GREECE'})
      o:TableData( 'ELO',{ 'GS','SOUTH GEORGIA AND THE SOUTH SANDWICH ISLANDS'})
      o:TableData( 'ELO',{ 'GT','GUATEMALA'})
      o:TableData( 'ELO',{ 'GU','GUAM'})
      o:TableData( 'ELO',{ 'GW','GUINEA-BISSAU'})
      o:TableData( 'ELO',{ 'GY','GUYANA'})
      o:TableData( 'ELO',{ 'HK','HONG KONG'})
      o:TableData( 'ELO',{ 'HM','HEARD ISLAND AND MCDONALD ISLANDS'})
      o:TableData( 'ELO',{ 'HN','HONDURAS'})
      o:TableData( 'ELO',{ 'HR','CROATIA'})
      o:TableData( 'ELO',{ 'HT','HAITI'})
      o:TableData( 'ELO',{ 'HU','HUNGARY'})
      o:TableData( 'ELO',{ 'ID','INDONESIA'})
      o:TableData( 'ELO',{ 'IE','IRELAND'})
      o:TableData( 'ELO',{ 'IL','ISRAEL'})
      o:TableData( 'ELO',{ 'IM','ISLE OF MAN'})
      o:TableData( 'ELO',{ 'IN','INDIA'})
      o:TableData( 'ELO',{ 'IO','BRITISH INDIAN OCEAN TERRITORY'})
      o:TableData( 'ELO',{ 'IQ','IRAQ'})
      o:TableData( 'ELO',{ 'IR','IRAN, ISLAMIC REPUBLIC OF'})
      o:TableData( 'ELO',{ 'IS','ICELAND'})
      o:TableData( 'ELO',{ 'IT','ITALY'})
      o:TableData( 'ELO',{ 'JE','JERSEY'})
      o:TableData( 'ELO',{ 'JM','JAMAICA'})
      o:TableData( 'ELO',{ 'JO','JORDAN'})
      o:TableData( 'ELO',{ 'JP','JAPAN'})
      o:TableData( 'ELO',{ 'KE','KENYA'})
      o:TableData( 'ELO',{ 'KG','KYRGYZSTAN'})
      o:TableData( 'ELO',{ 'KH','CAMBODIA'})
      o:TableData( 'ELO',{ 'KI','KIRIBATI'})
      o:TableData( 'ELO',{ 'KM','COMOROS'})
      o:TableData( 'ELO',{ 'KN','SAINT KITTS AND NEVIS'})
      o:TableData( 'ELO',{ 'KP',"KOREA, DEMOCRATIC PEOPLE'S REPUBLIC OF"})
      o:TableData( 'ELO',{ 'KR','KOREA, REPUBLIC OF'})
      o:TableData( 'ELO',{ 'KW','KUWAIT'})
      o:TableData( 'ELO',{ 'KY','CAYMAN ISLANDS'})
      o:TableData( 'ELO',{ 'KZ','KAZAKHSTAN'})
      o:TableData( 'ELO',{ 'LA',"LAO PEOPLE'S DEMOCRATIC REPUBLIC"})
      o:TableData( 'ELO',{ 'LB','LEBANON'})
      o:TableData( 'ELO',{ 'LC','SAINT LUCIA'})
      o:TableData( 'ELO',{ 'LI','LIECHTENSTEIN'})
      o:TableData( 'ELO',{ 'LK','SRI LANKA'})
      o:TableData( 'ELO',{ 'LR','LIBERIA'})
      o:TableData( 'ELO',{ 'LS','LESOTHO'})
      o:TableData( 'ELO',{ 'LT','LITHUANIA'})
      o:TableData( 'ELO',{ 'LU','LUXEMBOURG'})
      o:TableData( 'ELO',{ 'LV','LATVIA'})
      o:TableData( 'ELO',{ 'LY','LIBYAN ARAB JAMAHIRIYA'})
      o:TableData( 'ELO',{ 'MA','MOROCCO'})
      o:TableData( 'ELO',{ 'MC','MONACO'})
      o:TableData( 'ELO',{ 'MD','MOLDOVA, REPUBLIC OF'})
      o:TableData( 'ELO',{ 'ME','MONTENEGRO'})
      o:TableData( 'ELO',{ 'MF','SAINT MARTIN'})
      o:TableData( 'ELO',{ 'MG','MADAGASCAR'})
      o:TableData( 'ELO',{ 'MH','MARSHALL ISLANDS'})
      o:TableData( 'ELO',{ 'MK','MACEDONIA, THE FORMER YUGOSLAV REPUBLIC OF'})
      o:TableData( 'ELO',{ 'ML','MALI'})
      o:TableData( 'ELO',{ 'MM','MYANMAR'})
      o:TableData( 'ELO',{ 'MN','MONGOLIA'})
      o:TableData( 'ELO',{ 'MO','MACAO'})
      o:TableData( 'ELO',{ 'MP','NORTHERN MARIANA ISLANDS'})
      o:TableData( 'ELO',{ 'MQ','MARTINIQUE'})
      o:TableData( 'ELO',{ 'MR','MAURITANIA'})
      o:TableData( 'ELO',{ 'MS','MONTSERRAT'})
      o:TableData( 'ELO',{ 'MT','MALTA'})
      o:TableData( 'ELO',{ 'MU','MAURITIUS'})
      o:TableData( 'ELO',{ 'MV','MALDIVES'})
      o:TableData( 'ELO',{ 'MW','MALAWI'})
      o:TableData( 'ELO',{ 'MX','MEXICO'})
      o:TableData( 'ELO',{ 'MY','MALAYSIA'})
      o:TableData( 'ELO',{ 'MZ','MOZAMBIQUE'})
      o:TableData( 'ELO',{ 'NA','NAMIBIA'})
      o:TableData( 'ELO',{ 'NC','NEW CALEDONIA'})
      o:TableData( 'ELO',{ 'NE','NIGER'})
      o:TableData( 'ELO',{ 'NF','NORFOLK ISLAND'})
      o:TableData( 'ELO',{ 'NG','NIGERIA'})
      o:TableData( 'ELO',{ 'NI','NICARAGUA'})
      o:TableData( 'ELO',{ 'NL','NETHERLANDS'})
      o:TableData( 'ELO',{ 'NO','NORWAY'})
      o:TableData( 'ELO',{ 'NP','NEPAL'})
      o:TableData( 'ELO',{ 'NR','NAURU'})
      o:TableData( 'ELO',{ 'NU','NIUE'})
      o:TableData( 'ELO',{ 'NZ','NEW ZEALAND'})
      o:TableData( 'ELO',{ 'OM','OMAN'})
      o:TableData( 'ELO',{ 'PA','PANAMA'})
      o:TableData( 'ELO',{ 'PE','PERU'})
      o:TableData( 'ELO',{ 'PF','FRENCH POLYNESIA'})
      o:TableData( 'ELO',{ 'PG','PAPUA NEW GUINEA'})
      o:TableData( 'ELO',{ 'PH','PHILIPPINES'})
      o:TableData( 'ELO',{ 'PK','PAKISTAN'})
      o:TableData( 'ELO',{ 'PL','POLAND'})
      o:TableData( 'ELO',{ 'PM','SAINT PIERRE AND MIQUELON'})
      o:TableData( 'ELO',{ 'PN','PITCAIRN'})
      o:TableData( 'ELO',{ 'PR','PUERTO RICO'})
      o:TableData( 'ELO',{ 'PS','PALESTINE'})
      o:TableData( 'ELO',{ 'PT','PORTUGAL'})
      o:TableData( 'ELO',{ 'PW','PALAU'})
      o:TableData( 'ELO',{ 'PY','PARAGUAY'})
      o:TableData( 'ELO',{ 'QA','QATAR'})
      o:TableData( 'ELO',{ 'RE','R UNION'})
      o:TableData( 'ELO',{ 'RO','ROMANIA'})
      o:TableData( 'ELO',{ 'RS','SERBIA'})
      o:TableData( 'ELO',{ 'RU','RUSSIAN FEDERATION'})
      o:TableData( 'ELO',{ 'RW','RWANDA'})
      o:TableData( 'ELO',{ 'SA','SAUDI ARABIA'})
      o:TableData( 'ELO',{ 'SB','SOLOMON ISLANDS'})
      o:TableData( 'ELO',{ 'SC','SEYCHELLES'})
      o:TableData( 'ELO',{ 'SD','SUDAN'})
      o:TableData( 'ELO',{ 'SE','SWEDEN'})
      o:TableData( 'ELO',{ 'SG','SINGAPORE'})
      o:TableData( 'ELO',{ 'SH','SAINT HELENA'})
      o:TableData( 'ELO',{ 'SI','SLOVENIA'})
      o:TableData( 'ELO',{ 'SJ','SVALBARD AND JAN MAYEN'})
      o:TableData( 'ELO',{ 'SK','SLOVAKIA'})
      o:TableData( 'ELO',{ 'SL','SIERRA LEONE'})
      o:TableData( 'ELO',{ 'SM','SAN MARINO'})
      o:TableData( 'ELO',{ 'SN','SENEGAL'})
      o:TableData( 'ELO',{ 'SO','SOMALIA'})
      o:TableData( 'ELO',{ 'SR','SURINAME'})
      o:TableData( 'ELO',{ 'SS','SOUTH SUDAN'})
      o:TableData( 'ELO',{ 'ST','SAO TOME AND PRINCIPE'})
      o:TableData( 'ELO',{ 'SV','EL SALVADOR'})
      o:TableData( 'ELO',{ 'SX','SINT MAARTEN'})
      o:TableData( 'ELO',{ 'SY','SYRIAN ARAB REPUBLIC'})
      o:TableData( 'ELO',{ 'SZ','SWAZILAND'})
      o:TableData( 'ELO',{ 'TC','TURKS AND CAICOS ISLANDS'})
      o:TableData( 'ELO',{ 'TD','CHAD'})
      o:TableData( 'ELO',{ 'TG','TOGO'})
      o:TableData( 'ELO',{ 'TH','THAILAND'})
      o:TableData( 'ELO',{ 'TJ','TAJIKISTAN'})
      o:TableData( 'ELO',{ 'TK','TOKELAU'})
      o:TableData( 'ELO',{ 'TL','TIMOR-LESTE'})
      o:TableData( 'ELO',{ 'TM','TURKMENISTAN'})
      o:TableData( 'ELO',{ 'TN','TUNISIA'})
      o:TableData( 'ELO',{ 'TO','TONGA'})
      o:TableData( 'ELO',{ 'TR','TURKEY'})
      o:TableData( 'ELO',{ 'TT','TRINIDAD AND TOBAGO'})
      o:TableData( 'ELO',{ 'TV','TUVALU'})
      o:TableData( 'ELO',{ 'TW','TAIWAN, PROVINCE OF CHINA'})
      o:TableData( 'ELO',{ 'TZ','TANZANIA, UNITED REPUBLIC OF'})
      o:TableData( 'ELO',{ 'UA','UKRAINE'})
      o:TableData( 'ELO',{ 'UG','UGANDA'})
      o:TableData( 'ELO',{ 'UM','UNITED STATES MINOR OUTLYING ISLANDS'})
      o:TableData( 'ELO',{ 'US','UNITED STATES'})
      o:TableData( 'ELO',{ 'UY','URUGUAY'})
      o:TableData( 'ELO',{ 'UZ','UZBEKISTAN'})
      o:TableData( 'ELO',{ 'VA','HOLY SEE {VATICAN CITY STATE)'})
      o:TableData( 'ELO',{ 'VC','SAINT VINCENT AND THE GRENADINES'})
      o:TableData( 'ELO',{ 'VE','VENEZUELA'})
      o:TableData( 'ELO',{ 'VG','VIRGIN ISLANDS, BRITISH'})
      o:TableData( 'ELO',{ 'VI','VIRGIN ISLANDS, US'})
      o:TableData( 'ELO',{ 'VN','VIET NAM'})
      o:TableData( 'ELO',{ 'VU','VANUATU'})
      o:TableData( 'ELO',{ 'WF','WALLIS AND FUTUNA'})
      o:TableData( 'ELO',{ 'WS','SAMOA'})
      o:TableData( 'ELO',{ 'XZ','INSTALLATIONS IN INTERNATIONAL WATERS'})
      o:TableData( 'ELO',{ 'YE','YEMEN'})
      o:TableData( 'ELO',{ 'YT','MAYOTTE'})
      o:TableData( 'ELO',{ 'ZA','SOUTH AFRICA'})
      o:TableData( 'ELO',{ 'ZM','ZAMBIA'})
      o:TableData( 'ELO',{ 'ZW','ZIMBABWE'})
      o:TableData( 'ELO',{ 'TF','FRENCH SOUTHERN TERRITORIES'})

   endif

return nil

static function cargaEVN(o)

   if AvFlags("DU-E2") .And. !EVN->(DBSeek(xFilial("EVN") + PadR("1001", len(EVN->EVN_CODIGO)) + PadR("CUS", len(EVN->EVN_GRUPO))))
      o:TableStruct("EVN",{"EVN_CODIGO","EVN_GRUPO","EVN_DESCRI"},1)
      o:TableData( 'EVN',{ '1001'      ,'CUS'      ,'Por conta própria'})
      o:TableData( 'EVN',{ '1002'      ,'CUS'      ,'Por conta e ordem de terceiros'})
      o:TableData( 'EVN',{ '1003'      ,'CUS'      ,'Por operador de remessa postal ou expressa'})
      o:TableData( 'EVN',{ '2001'      ,'AHZ'      ,'DU-E a posteriori'})
      o:TableData( 'EVN',{ '2002'      ,'AHZ'      ,'Embarque antecipado'})
      o:TableData( 'EVN',{ '2003'      ,'AHZ'      ,'Exportação sem saída da mercadoria do país'})
      o:TableData( 'EVN',{ '4001'      ,'TRA'      ,'Meios próprios ou por reboque'})
      o:TableData( 'EVN',{ '4002'      ,'TRA'      ,'Dutos'})
      o:TableData( 'EVN',{ '4003'      ,'TRA'      ,'Linhas de transmissão'})
      o:TableData( 'EVN',{ '4004'      ,'TRA'      ,'Em mãos'})
      o:TableData( 'EVN',{ '3001'      ,'ACG'      ,'Bagagem desacompanhada'})
      o:TableData( 'EVN',{ '3002'      ,'ACG'      ,'Bens de viajante não incluídos no conceito de bagagem'})
      o:TableData( 'EVN',{ '3003'      ,'ACG'      ,'Retorno de mercadoria ao exterior antes do registro da DI'})
      o:TableData( 'EVN',{ '3004'      ,'ACG'      ,'Embarque antecipado'})
      o:TableData( 'EVN',{ '5001'      ,'PRI'      ,'Carga viva'})
      o:TableData( 'EVN',{ '5002'      ,'PRI'      ,'Carga perecível'})
      o:TableData( 'EVN',{ '5003'      ,'PRI'      ,'Carga perigosa'})
      o:TableData( 'EVN',{ '5006'      ,'PRI'      ,'Partes/peças de aeronave'})
   endif

return nil

static function cargaEC6(o)
   local nInc   := 0
   local cAlias := "EC6"
   local nTotal := 0

   if( select(cAlias) == 0, ChkFile(cAlias),nil)

   if Select(cAlias) > 0
      (cAlias)->(DbSetOrder(1))
      If !(cAlias)->(DbSeek(xFilial()))
         If xFilial(cAlias) <> Space(FWSizeFilial()) .And. (cAlias)->(DbSeek(Space(FWSizeFilial())))
            nTotal := (cAlias)->(FCount())
            While (cAlias)->EC6_FILIAL == Space(FWSizeFilial())
               nPos := (cAlias)->(Recno())
               For nInc := 1 to nTotal
                  M->&((cAlias)->(FIELDNAME(nInc))) := (cAlias)->(FieldGet(nInc))
               Next nInc
               M->EC6_FILIAL := xFilial(cAlias)
               (cAlias)->(RecLock(cAlias, .T.))
               AvReplace("M", cAlias)
               (cAlias)->(MsUnlock())
               (cAlias)->(DbGoTo(nPos))
               (cAlias)->(DbSkip())
            EndDo
         EndIf
      EndIf
   endif

return nil

static function EEDadosEJ0(o)

   if ChkFile("EJ0") .And. ChkFile("EJ1") .And. ChkFile("EJ2")
      o:TableStruct('EJ0',{'EJ0_FILIAL','EJ0_COD','EJ0_DESC'                            ,'EJ0_ENTR','EJ0_CHITEM','EJ0_TIPO','EJ0_CONSLD','EJ0_CHUSLD','EJ0_RE','EJ0_ADICAO','EJ0_CRITER','EJ0_MNTOBX'                                         ,'EJ0_CONDBX'          ,'EJ0_VALID'},1)
      o:TableData("EJ0",{xFilial("EJ0"),"01","Admissão Temporária de Embalagem","SW3",""          ,"E"       ,"2"         ,""          ,"1"     ,"1"         ,""          ,"BTN_MK_TDS_ITS_PO|DESMARCA_IT_PO|MK_IT_PO|BTN_MK_IT","                    ","                    "},,.F.) //STR0199 "Admissão Temporária de Embalagem   "
      o:TableData("EJ0",{xFilial("EJ0"),"01","Admissão Temporária de Embalagem","SW5","                                                                                                                                                                                                        ","E","2","                                                                                                                                                                                                        ","1","1","                    ","BTN_MK_IT_PLI|DESMARCA_IT_PLI|MARCATODOS_ITS_PLI|MARCA_ITS_PLI                                      ","                    ","                    "},,.F.)//STR0199 "Admissão Temporária de Embalagem   "
      o:TableData("EJ0",{xFilial("EJ0"),"01","Admissão Temporária de Embalagem","SW8","xFilial('SW8')+#SW6#->W6_HAWB+#SW9#->W9_INVOICE+#SW8#->W8_PO_NUM+#SW8#->W8_POSICAO+#SW8#->W8_PGI_NUM                                                                                                    ","E","1","EJ3_DI+EJ3_ADICAO+ EJ3_COD_I                                                                                                                                                                            ","1","1","                    ","MARC_TDS_EST|BTN_PRINC_EMB|MARC_IT_EST|MARC_EST_IV                                                  ","CondGrvCtrlEmb      ","VldGrvCtrlEmb       "},,.F.)//STR0199 "Admissão Temporária de Embalagem   "
      o:TableData("EJ0",{xFilial("EJ0"),"02","Reexportação de embalagem admitida temporariamente","EE8","xFilial('EE8')+#EE8#->EE8_PEDIDO+#EE8#->EE8_SEQUEN+#EE8#->EE8_COD_I                                                                                                                                     ","S","1","                                                                                                                                                                                                        ","1","1","EASYFIFO            ","BTN_IT_EE8|BTN_EXC_PED                                                                              ","                    ","                    "},,.F.)//STR0200 "Reexportação de embalagem admitida temporariamente"
      o:TableData("EJ0",{xFilial("EJ0"),"02","Reexportação de embalagem admitida temporariamente","EE9","xFilial('EE9')+#EEC#->EEC_PREEMB+#EE9#->EE9_SEQEMB                                                                                                                                                      ","S","1","                                                                                                                                                                                                        ","1","1","EASYFIFO            ","EXC_EMB|DESMARC_IT|MARC_ITS_EMB                                                                     ","                    ","VldGrvCtrlEmb       "},,.F.)//STR0200 "Reexportação de embalagem admitida temporariamente"
      o:TableData("EJ0",{xFilial("EJ0"),"03",If( cPaisLoc $ "ANG|PTG", "Exportação temporária de embalagem", "Exportação Temporária de Embalagem" ),"EE8","                                                                                                                                                                                                        ","E","2","                                                                                                                                                                                                        ","1","1","                    ","BTN_IT_EE8|BTN_EXC_PED                                                                              ","                    ","                    "},,.F.)//STR0201 "Exportação Temporária de Embalagem"
      o:TableData("EJ0",{xFilial("EJ0"),"03",If( cPaisLoc $ "ANG|PTG", "Exportação temporária de embalagem", "Exportação Temporária de Embalagem" ),"EE9","xFilial('EE9')+#EEC#->EEC_PREEMB+#EE9#->EE9_SEQEMB                                                                                                                                                      ","E","1","EJ3_PREEMB+EJ3_COD_I                                                                                                                                                                                        ","1","1","                    ","EXC_EMB|DESMARC_IT|MARC_ITS_EMB                                                                     ","                    ","VldGrvCtrlEmb       "},,.F.)//STR0201 "Exportação Temporária de Embalagem"
      o:TableData("EJ0",{xFilial("EJ0"),"04","Reimportação de embalagem admitida temporariamente","SW3","xFilial('SW3')+#SW3#->W3_PO_NUM+#SW3#->W3_POSICAO                                                                                                                                                       ","S","1","                                                                                                                                                                                                        ","1","1","EASYFIFO            ","BTN_MK_TDS_ITS_PO|DESMARCA_IT_PO|MK_IT_PO|BTN_MK_IT                                                 ","                    ","                    "},,.F.) //STR0202 "Reimportação de embalagem admitida temporariamente          "
      o:TableData("EJ0",{xFilial("EJ0"),"04","Reimportação de embalagem admitida temporariamente","SW5","                                                                                                                                                                                                        ","S","2","                                                                                                                                                                                                        ","1","1","EASYFIFO            ","BTN_MK_IT_PLI|DESMARCA_IT_PLI|MARCATODOS_ITS_PLI|MARCA_ITS_PLI                                      ","                    ","                    "},,.F.) //STR0202 "Reimportação de embalagem admitida temporariamente          "
      o:TableData("EJ0",{xFilial("EJ0"),"04","Reimportação de embalagem admitida temporariamente","SW8","xFilial('SW8')+#SW6#->W6_HAWB+#SW9#->W9_INVOICE+#SW8#->W8_PO_NUM+#SW8#->W8_POSICAO+#SW8#->W8_PGI_NUM                                                                                                    ","S","1","                                                                                                                                                                                                        ","1","1","EASYFIFO            ","MARC_TDS_EST|BTN_PRINC_EMB|MARC_IT_EST|MARC_EST_IV                                                  ","CondGrvCtrlEmb      ","VldGrvCtrlEmb       "},,.F.)//STR0202 "Reimportação de embalagem admitida temporariamente          "

      o:TableStruct('EJ1',{'EJ1_FILIAL','EJ1_CODE','EJ1_ENTR','EJ1_CODS','EJ1_SAIDA'},1)
      o:TableData('EJ1',{xFilial("EJ1"),'01','SW8','02','EE8'},,.F.)
      o:TableData('EJ1',{xFilial("EJ1"),'01','SW8','02','EE9'},,.F.)
      o:TableData('EJ1',{xFilial("EJ1"),'03','EE9','04','SW3'},,.F.)
      o:TableData('EJ1',{xFilial("EJ1"),'03','EE9','04','SW8'},,.F.)

      o:TableStruct('EJ2',{'EJ2_FILIAL','EJ2_CODE','EJ2_ENTR','EJ2_DE'          ,'EJ2_PARA'},1)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8","#SW6#->W6_DI_NUM","EJ3_DI"  },,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8","#SW6#->W6_DTREG_D","EJ3_DATA                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8","#SW8#->W8_ADICAO                                                                                                                                                                                        ","EJ3_ADICAO                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8",'BUSCA_UM(#SW8#->W8_COD_I+#SW8#->W8_FABR+#SW8#->W8_FORN,#SW8#->W8_CC+#SW8#->W8_SI_NUM, EICRetLoja("#SW8#", "W8_FABLOJ"), EICRetLoja("#SW8#", "W8_FORLOJ"))                                               ',"EJ3_UM                                                                                                                                                                                                  "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8","#SW8#->W8_QTDE                                                                                                                                                                                          ","EJ3_QTD                                                                                                                                                                                                 "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8","#SW8#->W8_COD_I                                                                                                                                                                                         ","EJ3_COD_I                                                                                                                                                                                               "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8","#SW8#->W8_PO_NUM                                                                                                                                                                                        ","EJ3_PO_NUM                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8","#SW8#->W8_POSICAO                                                                                                                                                                                       ","EJ3_POSICA                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8","#SW6#->W6_HAWB                                                                                                                                                                                          ","EJ3_HAWB                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8","#SW8#->W8_PGI_NUM                                                                                                                                                                                       ","EJ3_PGI_NU                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8","#SW8#->W8_INVOICE                                                                                                                                                                                       ","EJ3_INVOIC                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8","#SW7#->W7_PESO * #SW8#->W8_QTDE                                                                                                                                                                         ","EJ3_PESO                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE8","#EE8#->EE8_UNIDAD                                                                                                                                                                                       ","EJ3_UM                                                                                                                                                                                                  "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE8","#EE8#->EE8_SLDINI                                                                                                                                                                                       ","EJ3_QTD                                                                                                                                                                                                 "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE8","#EE8#->EE8_COD_I                                                                                                                                                                                        ","EJ3_COD_I                                                                                                                                                                                               "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE8","#EE8#->EE8_PEDIDO                                                                                                                                                                                       ","EJ3_PEDIDO                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE8","#EE8#->EE8_PSLQUN * #EE8#->EE8_SLDINI                                                                                                                                                                   ","EJ3_PESO                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE8","#EE8#->EE8_SEQUEN                                                                                                                                                                                       ","EJ3_SEQUEN                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE8","dDataBase                                                                                                                                                                                               ","EJ3_DATA                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE9","#EE9#->EE9_UNIDAD                                                                                                                                                                                       ","EJ3_UM                                                                                                                                                                                                  "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE9","#EE9#->EE9_SLDINI                                                                                                                                                                                       ","EJ3_QTD                                                                                                                                                                                                 "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE9","#EE9#->EE9_COD_I                                                                                                                                                                                        ","EJ3_COD_I                                                                                                                                                                                               "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE9","IIf( EEC->(FieldPos('EEC_NRODUE')) == 0 .Or. !Empty(#EE9#->EE9_RE), #EE9#->EE9_RE , #EEC#->EEC_NRODUE )                                                                                                  ","EJ3_RE                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE9","IIf( EEC->(FieldPos('EEC_DTDUE')) > 0 .And. !Empty(#EEC#->EEC_DTDUE), #EEC#->EEC_DTDUE, IIF(Empty(#EE9#->EE9_DTRE),IIF(Empty(#EEC#->EEC_DTEMBA),#EEC#->EEC_DTPROC,#EEC#->EEC_DTEMBA),#EE9#->EE9_DTRE))  ","EJ3_DATA                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE9","#EEC#->EEC_PREEMB                                                                                                                                                                                       ","EJ3_PREEMB                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE9","#EE9#->EE9_SEQEMB                                                                                                                                                                                       ","EJ3_SEQEMB                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE9","#EE9#->EE9_PEDIDO                                                                                                                                                                                       ","EJ3_PEDIDO                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE9","#EE9#->EE9_SEQUEN                                                                                                                                                                                       ","EJ3_SEQUEN                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE9","#EE9#->EE9_PSLQUN * #EE9#->EE9_SLDINI                                                                                                                                                                   ","EJ3_PESO                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"03","EE9","#EE9#->EE9_UNIDAD                                                                                                                                                                                       ","EJ3_UM                                                                                                                                                                                                  "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"03","EE9","#EE9#->EE9_SLDINI                                                                                                                                                                                       ","EJ3_QTD                                                                                                                                                                                                 "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"03","EE9","#EE9#->EE9_COD_I                                                                                                                                                                                        ","EJ3_COD_I                                                                                                                                                                                               "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"03","EE9","IIf( EEC->(FieldPos('EEC_NRODUE')) == 0 .Or. !Empty(#EE9#->EE9_RE), #EE9#->EE9_RE , #EEC#->EEC_NRODUE )                                                                                                  ","EJ3_RE                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"03","EE9","IIf( EEC->(FieldPos('EEC_DTDUE')) > 0 .And. !Empty(#EEC#->EEC_DTDUE), #EEC#->EEC_DTDUE, IIF(Empty(#EE9#->EE9_DTRE),IIF(Empty(#EEC#->EEC_DTEMBA),#EEC#->EEC_DTPROC,#EEC#->EEC_DTEMBA),#EE9#->EE9_DTRE))          ","EJ3_DATA                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"03","EE9","#EEC#->EEC_PREEMB                                                                                                                                                                                       ","EJ3_PREEMB                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"03","EE9","#EE9#->EE9_SEQEMB                                                                                                                                                                                       ","EJ3_SEQEMB                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"03","EE9","#EE9#->EE9_PEDIDO                                                                                                                                                                                       ","EJ3_PEDIDO                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"03","EE9","#EE9#->EE9_SEQUEN                                                                                                                                                                                       ","EJ3_SEQUEN                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"03","EE9","#EE9#->EE9_PSLQUN * #EE9#->EE9_SLDINI                                                                                                                                                                   ","EJ3_PESO                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW3",'BUSCA_UM(#SW3#->W3_COD_I+#SW3#->W3_FABR +#SW3#->W3_FORN,#SW3#->W3_CC+#SW3#->W3_SI_NUM,EICRetLoja("#SW3#", "W3_FABLOJ"), EICRetLoja("#SW3#", "W3_FORLOJ"))                                               ',"EJ3_UM                                                                                                                                                                                                  "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW3","#SW3#->W3_QTDE                                                                                                                                                                                          ","EJ3_QTD                                                                                                                                                                                                 "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW3","#SW3#->W3_COD_I                                                                                                                                                                                         ","EJ3_COD_I                                                                                                                                                                                               "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW3","#SW3#->W3_PO_NUM                                                                                                                                                                                        ","EJ3_PO_NUM                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW3","#SW3#->W3_POSICAO                                                                                                                                                                                       ","EJ3_POSICA                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW3","#SW3#->W3_PESOL * #SW3#->W3_QTDE                                                                                                                                                                        ","EJ3_PESO                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW3","dDataBase                                                                                                                                                                                               ","EJ3_DATA                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8","#SW6#->W6_DTREG_D                                                                                                                                                                                       ","EJ3_DATA                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8","#SW6#->W6_DI_NUM                                                                                                                                                                                        ","EJ3_DI                                                                                                                                                                                                  "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8","#SW8#->W8_ADICAO                                                                                                                                                                                        ","EJ3_ADICAO                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8",'BUSCA_UM(#SW8#->W8_COD_I+#SW8#->W8_FABR+#SW8#->W8_FORN,#SW8#->W8_CC+#SW8#->W8_SI_NUM, EICRetLoja("#SW8#", "W8_FABLOJ"), EICRetLoja("#SW8#", "W8_FORLOJ"))                                               ',"EJ3_UM                                                                                                                                                                                                  "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8","#SW8#->W8_QTDE                                                                                                                                                                                          ","EJ3_QTD                                                                                                                                                                                                 "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8","#SW8#->W8_COD_I                                                                                                                                                                                         ","EJ3_COD_I                                                                                                                                                                                               "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8","#SW8#->W8_PO_NUM                                                                                                                                                                                        ","EJ3_PO_NUM                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8","#SW8#->W8_POSICAO                                                                                                                                                                                       ","EJ3_POSICA                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8","#SW6#->W6_HAWB                                                                                                                                                                                          ","EJ3_HAWB                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8","#SW8#->W8_PGI_NUM                                                                                                                                                                                       ","EJ3_PGI_NU                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8","#SW8#->W8_INVOICE                                                                                                                                                                                       ","EJ3_INVOIC                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8","#SW7#->W7_PESO * #SW8#->W8_QTDE                                                                                                                                                                         ","EJ3_PESO                                                                                                                                                                                                "},,.F.)

   endif

return nil

static function CargEC6Adt(o)

   if !AvFlags("EEC_LOGIX")
      o:TableStruct("EC6" , {"EC6_FILIAL"     , "EC6_TPMODU"  ,"EC6_ID_CAM"   ,"EC6_IDENTC","EC6_RECDES" ,"EC6_TPTIT"}, 1)
      o:TableData("EC6"   , {xFilial("EC6")   , "EXPORT"      ,"605"          ,""          ,"1"	         , "RA"      },,.T.)

      o:TableStruct("EC6" , {"EC6_FILIAL"     , "EC6_TPMODU"  ,"EC6_ID_CAM"   ,"EC6_IDENTC","EC6_RECDES" ,"EC6_DESC"            , "EC6_TPTIT"}, 1)
      o:TableData("EC6"   , {xFilial("EC6")   , "EXPORT"      ,"606"          ,""          ,"1"	         ,"NOTA CRED. - CLIENTE", "NCC"      },,.F.)

      o:TableStruct("EC6" , {"EC6_FILIAL"     , "EC6_TPMODU"  ,"EC6_ID_CAM"   ,"EC6_IDENTC","EC6_RECDES" ,"EC6_DESC"            , "EC6_TPTIT"}, 1)
      o:TableData("EC6"   , {xFilial("EC6")   , "EXPORT"      ,"603"          ,""          ,"1"	         ,"ADIANT. PÓS EMBARQUE", ""      },,.F.)
   endif

return nil

static function EDadosEEA(o)
   local aIdioma    := FWGetSX5( "ID" )
   local cIdiomPort := ""
   local cIdiomIng  := ""
   local cIdiomEsp  := ""
   local cIdiomFra  := ""
   local lPosTipMod := EEA->(ColumnPos("EEA_TIPMOD")) > 0
   local ne         := 0
   local ns         := 0
   local aTableStruct := {}
   local aTableData   := {}
   local nPosCod
   local nPosArq

   cIdiomPort := retIdioma(aIdioma,"PORT. ")
   cIdiomIng := retIdioma(aIdioma,"INGLES")
   cIdiomEsp := retIdioma(aIdioma,"ESP.  ")
   cIdiomFra := retIdioma(aIdioma,"FRANCE")

   aadd(aTableStruct,{"EEA" ,{"EEA_FILIAL"   , "EEA_COD" , "EEA_FASE" , "EEA_TIPDOC" , "EEA_TITULO"                                                      , "EEA_CLADOC"             , "EEA_IDIOMA"                       , "EEA_ARQUIV"    , "EEA_FILTRO" , "EEA_RDMAKE"                                        ,"EEA_CNTLIM" , "EEA_CODMEM" , "EEA_ATIVO"  , "EEA_DOCAUT" , "EEA_DOCBAS" , "EEA_PE"  , "EEA_TABCAP" , "EEA_TABDET" , "EEA_INDICE" , "EEA_CHAVE"  , "EEA_IMPINV" , "EEA_MARCA"     },1})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "01"      , "2"        , "1-Carta"    , "ORDER ACKNOWLEDGMENT"                                            , "6-Outros"               , /*"INGLES-INGLES"   */ cIdiomIng   , "AVGLTT.RPT"    , ""           , "EXECBLOCK('EECPPE01',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "02"      , "2"        , "1-Carta"    , "ORDER CONFIRMATION"                                              , "6-Outros"               , /*"INGLES-INGLES"   */ cIdiomIng   , "PEDRECi.RPT"   , ""           , "EXECBLOCK('EECPPE02',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "03"      , "2"        , "1-Carta"    , "COMMERCIAL PROFORM"                                              , "1-Proforma"             , /*"INGLES-INGLES"   */ cIdiomIng   , "PROFING.RPT"   , ""           , "EXECBLOCK('EECPPE05',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "04"      , "3"        , "2-Documento", "SAQUE / CAMBIAL"                                                 , "6-Outros"               , /*"INGLES-INGLES"   */ cIdiomIng   , "SAC00001.RPT"  , ""           , "EXECBLOCK('EECPEM01',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "13"      , "3"        , "2-Documento", "PACKING LIST"                                                    , "3-Packing List"         , /*"INGLES-INGLES"   */ cIdiomIng   , "PAC00002.RPT"  , ""           , "EXECBLOCK('EECPEM10',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "14"      , "3"        , "2-Documento", "PACKING LIST"                                                    , "3-Packing List"         , /*"ESP.  -ESPANHOL" */ cIdiomEsp   , "PAC00003.RPT"  , ""           , "EXECBLOCK('EECPEM10',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "16"      , "3"        , "2-Documento", "C.O. ALADI (FIESP)"                                              , "4-Certificado de Origem", /*"INGLES-INGLES"   */ cIdiomIng   , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM13',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "20"      , "3"        , "1-Carta"    , "RESERVA DE PRAÇA"                                                , "6-Outros"               , /*"INGLES-INGLES"   */ cIdiomIng   , "AVGLTT.RPT"    , ""           , "EXECBLOCK('EECPEM17',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "23"      , "3"        , "2-Documento", "C.O. NORMAL (FIESP)"                                             , "4-Certificado de Origem", /*"INGLES-INGLES"   */ cIdiomIng   , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM20',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "25"      , "3"        , "2-Documento", "C.O. MERCOSUL (FIESP)"                                           , "4-Certificado de Origem", /*"INGLES-INGLES"   */ cIdiomIng   , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM24',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "26"      , "3"        , "2-Documento", "MEMORANDO DE EXPORTAÇÃO"                                         , "6-Outros"               , /*"PORT. -PORTUGUES"*/ cIdiomPort  , "MEMEXP.RPT"    , ""           , "EXECBLOCK('EECPEM26',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "28"      , "3"        , "2-Documento", "INSTRUÇÃO DE EMBARQUE"                                           , "6-Outros"               , /*"INGLES-INGLES"   */ cIdiomIng   , "INS00002.RPT"  , ""           , "EXECBLOCK('EECPEM28',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "33"      , "3"        , "2-Documento", "SOLICITACAO PARA EMISSAO DE NOTA FISCAL PARA EXPORTACAO"         , "6-Outros"               , /*"INGLES-INGLES"   */ cIdiomIng   , "EMNFEXP.RPT"   , ""           , "EXECBLOCK('EECPEM32',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "35"      , "2"        , "1-Carta"    , "PEDIDO CLIENTE"                                                  , "6-Outros"               , /*"ESP.  -ESPANHOL" */ cIdiomEsp   , "PEDREC.RPT"    , ""           , "EXECBLOCK('EECPPE02',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "36"      , "2"        , "1-Carta"    , "FACTURA PROFORMA"                                                , "1-Proforma"             , /*"ESP.  -ESPANHOL" */ cIdiomEsp   , "PROFESP.RPT"   , ""           , "EXECBLOCK('EECPPE05',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "37"      , "3"        , "2-Documento", "COMMERCIAL INVOICE"                                              , "2-Fatura"               , /*"INGLES-INGLES"   */ cIdiomIng   , "FATING.RPT"    , ""           , "EXECBLOCK('EECPEM11',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "38"      , "3"        , "2-Documento", "FACTURA COMERCIAL"                                               , "2-Fatura"               , /*"ESP.  -ESPANHOL" */ cIdiomEsp   , "FATESP.RPT"    , ""           , "EXECBLOCK('EECPEM11',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "39"      , "3"        , "2-Documento", "C.O. BOLIVIA (FIESP)"                                            , "4-Certificado de Origem", /*"INGLES-INGLES"   */ cIdiomIng   , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,'B')"                 , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "40"      , "3"        , "2-Documento", "C.O. CHILE (FIESP)"                                              , "4-Certificado de Origem", /*"INGLES-INGLES"   */ cIdiomIng   , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,'C')"                 , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "41"      , "3"        , "2-Documento", "AMOSTRA - INGLES"                                                , "6-Outros"               , /*"INGLES-INGLES"   */ cIdiomIng   , "FATAMI.RPT"    , ""           , "EXECBLOCK('EECPEM11',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "42"      , "3"        , "2-Documento", "AMOSTRA - ESPANHOL"                                              , "6-Outros"               , /*"ESP.  -ESPANHOL" */ cIdiomEsp   , "FATAME.RPT"    , ""           , "EXECBLOCK('EECPEM11',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "50"      , "3"        , "3-Relatorio", "MEMORANDO DE EXPORTAÇÃO"                                         , "6-Outros"               , /*"PORT. -PORTUGUES"*/ cIdiomPort  , "MEMEXP.RPT"    , ""           , "EXECBLOCK('EECPEM26',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "51"      , "3"        , "3-Relatorio", "STATUS DO PROCESSO"                                              , "6-Outros"               , /*"PORT. -PORTUGUES"*/ cIdiomPort  , "REL01.RPT"     , ""           , "EXECBLOCK('EECPRL01',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "52"      , "2"        , "3-Relatorio", "OPEN ORDERS"                                                     , "6-Outros"               , /*"INGLES-INGLES"   */ cIdiomIng   , "REL02.RPT"     , ""           , "EXECBLOCK('EECPRL02',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "53"      , "3"        , "3-Relatorio", "PROGRAMAÇÃO DE EMBARQUES"                                        , "6-Outros"               , /*"PORT. -PORTUGUES"*/ cIdiomPort  , "REL03.RPT"     , ""           , "EXECBLOCK('EECPRL03',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "54"      , "3"        , "3-Relatorio", "PROCESSOS POR VIA DE TRANSPORTE"                                 , "6-Outros"               , /*"PORT. -PORTUGUES"*/ cIdiomPort  , "REL04.RPT"     , ""           , "EXECBLOCK('EECPRL04',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "56"      , "3"        , "3-Relatorio", "PROCESSOS POR DATA DE ATRACAÇÃO"                                 , "6-Outros"               , /*"PORT. -PORTUGUES"*/ cIdiomPort  , "REL06.RPT"     , ""           , "EXECBLOCK('EECPRL06',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "57"      , "3"        , "3-Relatorio", "COMISSÕES PENDENTES"                                             , "6-Outros"               , /*"PORT. -PORTUGUES"*/ cIdiomPort  , "REL07.RPT"     , ""           , "EXECBLOCK('EECPRL07',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "58"      , "3"        , "3-Relatorio", "SHIPPED ORDERS"                                                  , "6-Outros"               , /*"INGLES-INGLES"   */ cIdiomIng   , "REL08.RPT"     , ""           , "EXECBLOCK('EECPRL08',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "59"      , "3"        , "3-Relatorio", "EXPORT REPORT"                                                   , "6-Outros"               , /*"INGLES-INGLES"   */ cIdiomIng   , "REL09.RPT"     , ""           , "EXECBLOCK('EECPRL09',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "60"      , "3"        , "2-Documento", "CONTROLE DE EMBARQUE"                                            , "6-Outros"               , /*"PORT. -PORTUGUES"*/ cIdiomPort  , "REL11.RPT"     , ""           , "EXECBLOCK('EECPRL10',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "61"      , "3"        , "3-Relatorio", "DEMONSTRATIVOS DE MERCADORIAS FATURADAS POREM NÃO EMBARCADAS"    , "6-Outros"               , /*"PORT. -PORTUGUES"*/ cIdiomPort  , "REL12.RPT"     , ""           , "EXECBLOCK('EECPRL12',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "62"      , "2"        , "3-Relatorio", "CARTEIRA DE PEDIDOS"                                             , "6-Outros"               , /*"PORT. -PORTUGUES"*/ cIdiomPort  , "REL13.RPT"     , ""           , "EXECBLOCK('EECPRL13',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "63"      , "3"        , "3-Relatorio", "RELATÓRIO DE EMBARQUES"                                          , "6-Outros"               , /*"PORT. -PORTUGUES"*/ cIdiomPort  , "REL14.RPT"     , ""           , "EXECBLOCK('EECPRL14',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "65"      , "3"        , "3-Relatorio", "VARIAÇÃO CAMBIAL"                                                , "6-Outros"               , /*"PORT. -PORTUGUES"*/ cIdiomPort  , "REL16.RPT"     , ""           , "EXECBLOCK('EECPRL16',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "66"      , "3"        , "3-Relatorio", "INTERNATIONAL RECEIVABLE ACCOUNT STATEMENT"                      , "6-Outros"               , /*"PORT. -PORTUGUES"*/ cIdiomPort  , "REL17.RPT"     , ""           , "EXECBLOCK('EECPRL17',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "67"      , "3"        , "2-Documento", "C.O. NORMAL (CEARA)"                                             , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM20',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "68"      , "3"        , "2-Documento", "C.O. NORMAL (RIO GRANDE DO SUL)"                                 , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM20',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "69"      , "3"        , "2-Documento", "C.O. NORMAL (ASSOCIACAO COMERCIAL DE SANTOS)"                    , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM20',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "70"      , "3"        , "2-Documento", "C.O. ALADI (CEARA)"                                              , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM13',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "71"      , "3"        , "2-Documento", "C.O. ALADI (RIO GRANDE DO SUL)"                                  , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM13',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "72"      , "3"        , "2-Documento", "C.O. ALADI (ASSOCIACAO COMERCIAL DE SANTOS)"                     , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM13',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "73"      , "3"        , "2-Documento", "C.O. MERCOSUL (CEARA)"                                           , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM24',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "74"      , "3"        , "2-Documento", "C.O. MERCOSUL (RIO GRANDE DO SUL)"                               , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM24',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "75"      , "3"        , "2-Documento", "C.O. MERCOSUL (ASSOCIACAO COMERCIAL DE SANTOS)"                  , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM24',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "76"      , "3"        , "2-Documento", "C.O. BOLIVIA (CEARA)"                                            , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,'B')"                 , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "77"      , "3"        , "2-Documento", "C.O. BOLIVIA (RIO GRANDE DO SUL)"                                , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,'B')"                 , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "78"      , "3"        , "2-Documento", "C.O. BOLIVIA (ASSOCIACAO COMERCIAL DE SANTOS)"                   , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,'B')"                 , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "79"      , "3"        , "2-Documento", "C.O. CHILE (CEARA)"                                              , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,'C')"                 , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "80"      , "3"        , "2-Documento", "C.O. CHILE (RIO GRANDE DO SUL)"                                  , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,'C')"                 , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "81"      , "3"        , "2-Documento", "C.O. CHILE (ASSOCIACAO COMERCIAL DE SANTOS)"                     , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,'C')"                 , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "82"      , "3"        , "3-Relatorio", "CUSTO REALIZADO"                                                 , "6-Outros"                , /*"PORT. -PORTUGUES"*/ cIdiomPort , "REL18.RPT"     , ""           , "EXECBLOCK('EECAF155',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "83"      , "3"        , "1-Carta"    , "CARTA REMESSA DE DOCUMENTOS"                                     , "6-Outros"                , /*"PORT. -PORTUGUES"*/ cIdiomPort , "PEM56.RPT"     , ""           , "EXECBLOCK('EECPEM56',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "84"      , "3"        , "2-Documento", "COMMERCIAL INVOICE (MODELO 4)"                                   , "2-Fatura"                , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM52I.RPT"    , ""           , "EXECBLOCK('EECPEM52',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "85"      , "3"        , "2-Documento", "FACTURA COMERCIAL (MODELO 4)"                                    , "2-Fatura"                , /*"ESP.  -ESPANHOL" */ cIdiomEsp  , "PEM52E.RPT"    , ""           , "EXECBLOCK('EECPEM52',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "86"      , "3"        , "2-Documento", "COMMERCIAL INVOICE (MODELO 4)"                                   , "2-Fatura"                , /*"FRANCE-FRANCES"  */ cIdiomFra  , "PEM52F.RPT"    , ""           , "EXECBLOCK('EECPEM52',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "87"      , "3"        , "2-Documento", "PACKING LIST (MODELO 3)"                                         , "3-Packing List"          , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM55I.RPT"    , ""           , "EXECBLOCK('EECPEM55',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "88"      , "3"        , "2-Documento", "LISTA DE EMPAQUE (MODELO 4)"                                     , "3-Packing List"          , /*"ESP.  -ESPANHOL" */ cIdiomEsp  , "PEM55E.RPT"    , ""           , "EXECBLOCK('EECPEM55',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "89"      , "3"        , "2-Documento", "PACKING LIST (MODELO 3)"                                         , "3-Packing List"          , /*"FRANCE-FRANCES"  */ cIdiomFra  , "PEM55F.RPT"    , ""           , "EXECBLOCK('EECPEM55',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "90"      , "3"        , "2-Documento", "SAQUE (MODELO 2)"                                                , "6-Outros"                , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM57.RPT"     , ""           , "EXECBLOCK('EECPEM57',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "91"      , "3"        , "2-Documento", "COMMERCIAL INVOICE (MODELO 3)"                                   , "2-Fatura"                , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM51.RPT"     , ""           , "EXECBLOCK('EECPEM51',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "92"      , "3"        , "2-Documento", "PACKING LIST (MODELO 2)"                                         , "3-Packing List"          , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM54.RPT"     , ""           , "EXECBLOCK('EECPEM54',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "93"      , "3"        , "2-Documento", "CERTIFICADO ORIGEM OIC"                                          , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM58',.F.,.F.)"                     , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "94"      , "3"        , "2-Documento", "COMMERCIAL INVOICE (MODELO 2)"                                   , "2-Fatura"                , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM50.RPT"     , ""           , "EXECBLOCK('EECPEM50',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "95"      , "2"        , "2-Documento", "PROFORMA INVOICE (MODELO 2)"                                     , "1-Proforma"              , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM49.RPT"     , ""           , "EXECBLOCK('EECPEM49',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "96"      , "3"        , "2-Documento", "C.O. ARABIA"                                                     , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "COARABIA.RPT"  , ""           , "EXECBLOCK('EECPEM45',.F.,.F.)"                     , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "97"      , "3"        , "2-Documento", "C.O. NORMAL (FIRJAN)"                                            , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM20',.F.,.F.,'RJ')"                , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "98"      , "3"        , "2-Documento", "C.O. ALADI (FIRJAN)"                                             , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM13',.F.,.F.,'RJ')"                , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "99"      , "3"        , "2-Documento", "C.O. MERCOSUL (FIRJAN)"                                          , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM24',.F.,.F.,'RJ')"                , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "100"     , "1"        , "3-Relatorio", "RELATÓRIO DE ADIANTAMENTO"                                       , "6-Outros"                , /*"INGLES-INGLES"   */ cIdiomIng  , "REL23.RPT"     , ""           , "EXECBLOCK('EECPRL23',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-100"   , "3"        , "2-Documento", "C.O. BOLIVIA (FIRJAN)"                                           , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,'RJ-B')"              , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-101"   , "3"        , "2-Documento", "C.O. CHILE (FIRJAN)"                                             , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,'RJ-C')"              , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-102"   , "3"        , "2-Documento", "C.O. CHILE (FIEB) (COM LAYOUT)"                                  , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM33.RPT"     , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,{'C','FIEB'})"        , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-103"   , "3"        , "2-Documento", "C.O. BOLIVIA (FIEB) (COM LAYOUT)"                                , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM33.RPT"     , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,{'B','FIEB'})"        , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-104"   , "3"        , "2-Documento", "C.O. CHILE (FIESP) (COM LAYOUT)"                                 , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM33.RPT"     , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,{'C','FIESP'})"       , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-105"   , "3"        , "2-Documento", "C.O. BOLIVIA (FIESP) (COM LAYOUT)"                               , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM33.RPT"     , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,{'B','FIESP'})"       , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-106"   , "3"        , "2-Documento", "C.O. CHILE (FEDERASUL) (COM LAYOUT)"                             , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM33.RPT"     , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,{'C','FEDERASUL'})"   , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-107"   , "3"        , "2-Documento", "C.O. BOLIVIA (FEDERASUL) (COM LAYOUT)"                           , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM61.RPT"     , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,{'B','FEDERASUL'})"   , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-108"   , "3"        , "2-Documento", "C.O. MERCOSUL - APENDICE I AO ANEXO IV (FIESP)"                  , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM61',.F.,.F.,{'FIESP'})"           , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-109"   , "3"        , "2-Documento", "C.O. MERCOSUL - APENDICE I AO ANEXO IV (ASSOC. COM. DE SANTOS)"  , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM61',.F.,.F.,{'SANTOS'})"          , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-110"   , "3"        , "2-Documento", "C.O. CHILE (FIEP) (COM LAYOUT)"                                  , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM33.RPT"     , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,{'C','FIEP'})"        , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-111"   , "3"        , "2-Documento", "C.O. BOLIVIA (FIEP) (COM LAYOUT)"                                , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM33.RPT"     , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,{'B','FIEP'})"        , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-112"   , "3"        , "2-Documento", "C.O. ALADI (FIEP) (COM LAYOUT)"                                  , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM59.RPT"     , ""           , "EXECBLOCK('EECPEM59',.F.,.F.,{'FIEP'})"            , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-113"   , "3"        , "2-Documento", "C.O. ALADI (FIESP) (COM LAYOUT)"                                 , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM59.RPT"     , ""           , "EXECBLOCK('EECPEM59',.F.,.F.,{'FIESP'})"           , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-114"   , "3"        , "2-Documento", "C.O. ALADI (FIEB) (COM LAYOUT)"                                  , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM59.RPT"     , ""           , "EXECBLOCK('EECPEM59',.F.,.F.,{'FIEB'})"            , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-115"   , "3"        , "2-Documento", "C.O. MERCOSUL (FIESP) (COM LAYOUT)"                              , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM60.RPT"     , ""           , "EXECBLOCK('EECPEM60',.F.,.F.,{'FIESP'})"           , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-116"   , "3"        , "2-Documento", "C.O. MERCOSUL (FIEP) (COM LAYOUT)"                               , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM60.RPT"     , ""           , "EXECBLOCK('EECPEM60',.F.,.F.,{'FIEP'})"            , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-117"   , "3"        , "2-Documento", "C.O. MERCOSUL (FEDERASUL) (COM LAYOUT)"                          , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM60.RPT"     , ""           , "EXECBLOCK('EECPEM60',.F.,.F.,{'FEDERASUL'})"       , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-118"   , "3"        , "2-Documento", "C.O. MERCOSUL (FIEB) (COM LAYOUT)"                               , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM60.RPT"     , ""           , "EXECBLOCK('EECPEM60',.F.,.F.,{'FIEB'})"            , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-119"   , "3"        , "2-Documento", "C.O. NORMAL (FIESP) (COM LAYOUT)"                                , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM20.RPT"     , ""           , "EXECBLOCK('EECPEM35',.F.,.F.,{'LAYOUT'})"          , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-120"   , "3"        , "3-Relatorio", "CONTROLE DE CAMBIAIS"                                            , "6-Outros"                , /*"PORT. -PORTUGUES"*/ cIdiomPort , "REL20.RPT"     , ""           , "EXECBLOCK('EECPRL20',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-121"   , "1"        , "3-Relatorio", "CONTRATOS DE CÂMBIO NO PERÍODO"                                  , "6-Outros"                , /*"PORT. -PORTUGUES"*/ cIdiomPort , "REL21.RPT"     , ""           , "EXECBLOCK('EECPRL21',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-130"   , "3"        , "2-Documento", "C.O. MERCOSUL (FIEP) (COM LAYOUT)"                               , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM70.RPT"     , ""           , "EXECBLOCK('EECPEM70',.F.,.F.,{'FIEP'})"            , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-131"   , "3"        , "2-Documento", "C.O. MERCOSUL - CHILE (FIEP) (COM LAYOUT)"                       , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM71.RPT"     , ""           , "EXECBLOCK('EECPEM71',.F.,.F.,{'C','FIEP'})"        , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-132"   , "3"        , "2-Documento", "C.O. MERCOSUL - BOLIVIA (FIEP) (COM LAYOUT)"                     , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM71.RPT"     , ""           , "EXECBLOCK('EECPEM71',.F.,.F.,{'B','FIEP'})"        , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-133"   , "3"        , "2-Documento", "C.O. ALADI (FIEP) (COM LAYOUT)"                                  , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM72.RPT"     , ""           , "EXECBLOCK('EECPEM72',.F.,.F.,{'FIEP'})"            , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-134"   , "3"        , "2-Documento", "C.O. ACORDO MERCOSUL- COLOMBIA, EQUADOR E VENEZUELA (COM LAYOUT)", "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM73.RPT"     , ""           , "EXECBLOCK('EECPEM73',.F.,.F.)"                     , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-135"   , "3"        , "2-Documento", "C.O. COMUM - FIEP (COM LAYOUT)"                                  , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM74.RPT"     , ""           , "EXECBLOCK('EECPEM74',.F.,.F.)"                     , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-136"   , "3"        , "2-Documento", "C.O. GSTP (FIEP) (COM LAYOUT)"                                   , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM75.RPT"     , ""           , "EXECBLOCK('EECPEM75',.F.,.F.)"                     , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-137"   , "3"        , "3-Relatorio", "RELATÓRIO DE PRÉ-CALCULO"                                        , "6-Outros"                , /*"PORT. -PORTUGUES"*/ cIdiomPort , "REL22.RPT"     , ""           , "U_EECPRL22()"                                      , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-139"   , "1"        , "3-Relatorio", "RELAÇÃO DE DESPESAS NACIONAIS"                                   , "6-Outros"                , /*"PORT. -PORTUGUES"*/ cIdiomPort , "REL25.RPT"     , ""           , "EXECBLOCK('EECPRL25',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-140"   , "3"        , "2-Documento", "PACKING LIST (MODELO 4)"                                         , "3-Packing List"          , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM76.RPT"     , ""           , "EXECBLOCK('EECPEM76',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-138"   , "2"        , "2-Documento", "PRÉ CUSTO"                                                       , "6-Outros"                , /*"PORT. -PORTUGUES"*/ cIdiomPort , "PC150.RPT"     , ""           , "EECPC150()"                                        , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "R-001"   , "1"        , "3-Relatorio", "EMBALAGENS ESPECIAIS"                                            , "6-Outros"                , /*"PORT. -PORTUGUES"*/ cIdiomPort , ""              , ""           , "EXECBLOCK('EASYADM100',.F.,.F.)"                   , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-146"   , "3"        , "2-Documento", "LISTA DE EMPAQUE (MODELO 2)"                                     , "3-Packing List"          , /*"ESP.  -ESPANHOL" */ cIdiomEsp  , "PEM55E.RPT"    , ""           , "EXECBLOCK('EECPEM55',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , "0"          , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-147"   , "3"        , "2-Documento", "FACTURA COMERCIAL (MODELO 2)"                                    , "2-Fatura"                , /*"ESP.  -ESPANHOL" */ cIdiomEsp  , "PEM52E.RPT"    , ""           , "EXECBLOCK('EECPEM52',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , "0"          , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-141"   , "3"        , "2-Documento", "INSTRUÇÃO DE EMBARQUE"                                           , "6-Outros"                , /*"PORT. -PORTUGUES"*/ cIdiomPort , "INS00002.RPT"  , ""           , "EXECBLOCK('EECPEM83',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-142"   , "3"        , "2-Documento", "INSTRUÇÃO DE EMBARQUE"                                           , "6-Outros"                , /*"ESP.  -ESPANHOL" */ cIdiomEsp  , "INS00002.RPT"  , ""           , "EXECBLOCK('EECPEM84',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-143"   , "3"        , "2-Documento", "PACKING LIST (MODELO 4)"                                         , "3-Packing List"          , /*"ESP.  -ESPANHOL" */ cIdiomEsp  , "PEM85.RPT"     , ""           , "EXECBLOCK('EECPEM85',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "3-RELATORIO" , "1"    , "3-Relatorio", "TABELA DE PREÇOS"                                                , "6-Outros"                , /*"PORT. -PORTUGUES"*/ cIdiomPort , "REL24.RPT"     , ""           , "EXECBLOCK('EECPRL24',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "F-001"   , "3"        , "2-Documento", "CERTIFICADO DE ORIGEM - FIERGS"                                  , "4-Certificado de origem" , /*"PORT. -PORTUGUES"*/ cIdiomPort , ""              , ""           , "AE108FIERGS()"                                     , ""           , ""           , "2"          , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})

   for ns:=1 to len(aTableStruct)
      if aTableStruct[ns][1] == "EEA" .and. lPosTipMod
         aadd(aTableStruct[ns][2],"EEA_TIPMOD")
      endif
      //                tabelas        -     campos        -      indice
      o:TableStruct(aTableStruct[ns][1],aTableStruct[ns][2],aTableStruct[ns][3])
   next

   If ValType(aTableStruct[1][2]) == "A"
      nPosCod := aScan(aTableStruct[1][2],{ |x| x == "EEA_COD" })
      nPosArq := aScan(aTableStruct[1][2],{ |x| x == "EEA_ARQUIV" })
   EndIf

   for ne := 1 to len(aTableData)
      aadd(aTableData[ne][2], if( aTableData[ne][1] == "EEA" .and. lPosTipMod .And. (aTableData[ne][2][nPosCod] == "37" .Or. "AVGLTT" $ aTableData[ne][2][nPosArq]), "1", "2"))
      //             tabela        ,   dados         ,   nil           ,   atualiza ?
      o:TableData(aTableData[ne][1],aTableData[ne][2],aTableData[ne][3],aTableData[ne][4])
   next

   o:TableStruct("EEA",{"EEA_FILIAL"   , "EEA_COD" , "EEA_TIPDOC" , "EEA_IDIOMA" },1)
   o:DelTableData('EEA'  ,{xFilial('EEA') , "14"    , "2-Documento" , "ESP."   })
   o:DelTableData('EEA'  ,{xFilial('EEA') , "60"    , "2-Documento" , "PORT."  })
   o:DelTableData('EEA'  ,{xFilial('EEA') , "A-130" , "2-Documento" , "INGLES" })
   o:DelTableData('EEA'  ,{xFilial('EEA') , "A-131" , "2-Documento" , "INGLES" })
   o:DelTableData('EEA'  ,{xFilial('EEA') , "A-132" , "2-Documento" , "INGLES" })
   o:DelTableData('EEA'  ,{xFilial('EEA') , "A-133" , "2-Documento" , "INGLES" })
   o:DelTableData('EEA'  ,{xFilial('EEA') , "A-134" , "2-Documento" , "INGLES" })
   o:DelTableData('EEA'  ,{xFilial('EEA') , "A-135" , "2-Documento" , "INGLES" })
   o:DelTableData('EEA'  ,{xFilial('EEA') , "A-136" , "2-Documento" , "INGLES" })
   o:DelTableData('EEA'  ,{xFilial('EEA') , "A-137" , "3-Relatorio" , "PORT."  })
   o:DelTableData('EEA'  ,{xFilial('EEA') , "100"   , "3"           , "INGLES" })
   o:DelTableData('EEA'  ,{xFilial('EEA') , "A-138" , "2"           , "PORT."  })
   o:DelTableData('EEA'  ,{xFilial('EEA') , "A-139" , "3"           , "PORT."  })
   o:DelTableData('EEA'  ,{xFilial('EEA') , "A-140" , "2"           , "INGLES" })

return nil

static function retIdioma(aIdioma,cChave)
   Local cRet := ""
   Local nPos := 0

   if ( nPos :=  ascan( aIdioma, {|x| x[3] == AVKEY( cChave, "X5_CHAVE" ) }) ) > 0
      cRet := aIdioma[nPos][3] + "-" + aIdioma[nPos][4]
   endif

return cRet

static function AtuDoc()
   Local cQryUpd
   Local cFilSYA := xFilial("SY0")
   Local cFilEEA := xFilial("EEA")
   Local dDataLimite := MonthSub(dDataBase,6)
   Local cTableEEA := RetSqlName("EEA")
   Local cTableSY0 := RetSqlName("SY0")
   Local cListArq := "(", cListNotIn := "("
   Local i:=0
   Local aListArq := {}
   Local cQryEEA


   aadd(aListArq,'34')
   aadd(aListArq,'10')
   aadd(aListArq,'17')
   aadd(aListArq,'7')
   aadd(aListArq,'19')
   aadd(aListArq,'22')
   aadd(aListArq,'21')
   aadd(aListArq,'55')
   aadd(aListArq,'18')
   aadd(aListArq,'15')
   aadd(aListArq,'6')
   aadd(aListArq,'27')
   aadd(aListArq,'11')
   aadd(aListArq,'9')
   aadd(aListArq,'8')
   aadd(aListArq,'4')
   aadd(aListArq,'33')
   aadd(aListArq,'30')
   aadd(aListArq,'29')
   aadd(aListArq,'93')
   aadd(aListArq,'F-001')
   aadd(aListArq,'12')
   aadd(aListArq,'31')
   aadd(aListArq,'32')
   aadd(aListArq,'68')
   aadd(aListArq,'97')
   aadd(aListArq,'A-119')
   aadd(aListArq,'23')
   aadd(aListArq,'67')
   aadd(aListArq,'69')
   aadd(aListArq,'74')
   aadd(aListArq,'99')
   aadd(aListArq,'A-115')
   aadd(aListArq,'25')
   aadd(aListArq,'A-116')
   aadd(aListArq,'A-130')
   aadd(aListArq,'A-118')
   aadd(aListArq,'A-117')
   aadd(aListArq,'73')
   aadd(aListArq,'75')
   aadd(aListArq,'A-131')
   aadd(aListArq,'A-132')
   aadd(aListArq,'A-108')
   aadd(aListArq,'A-109')
   aadd(aListArq,'A-136')
   aadd(aListArq,'A-135')
   aadd(aListArq,'80')
   aadd(aListArq,'A-101')
   aadd(aListArq,'A-104')
   aadd(aListArq,'40')
   aadd(aListArq,'A-110')
   aadd(aListArq,'A-102')
   aadd(aListArq,'A-106')
   aadd(aListArq,'79')
   aadd(aListArq,'81')
   aadd(aListArq,'77')
   aadd(aListArq,'A-100')
   aadd(aListArq,'A-105')
   aadd(aListArq,'39')
   aadd(aListArq,'A-111')
   aadd(aListArq,'A-103')
   aadd(aListArq,'A-107')
   aadd(aListArq,'76')
   aadd(aListArq,'78')
   aadd(aListArq,'96')
   aadd(aListArq,'71')
   aadd(aListArq,'98')
   aadd(aListArq,'A-113')
   aadd(aListArq,'16')
   aadd(aListArq,'A-112')
   aadd(aListArq,'A-133')
   aadd(aListArq,'A-114')
   aadd(aListArq,'70')
   aadd(aListArq,'72')
   aadd(aListArq,'A-134')
   aadd(aListArq,'24')
   aadd(aListArq,'5')

   //******************************************************************************************************
   //*
   //*                       Atenção não inverter a ordem da execução dessas operações
   //*  1o. Desativa os registros tipo Fax desde que tenha outro com mesmo código do tipo Carta
   //*  2O. Desativa os documentos não utilizados a mais de 6 meses respeitando a lista
   //*  3O. Atualiza os campos modelo padrao, modelo customizado e tipo modelo padrão conforme critérios no jira
   //******************************************************************************************************


   //1o. Desativa os registros tipo Fax desde que tenha outro com mesmo código do tipo Carta
   // script validado nos três bancos pelo query analyzer da Totvs
   cQryEEA := "SELECT EEA1.EEA_COD,EEA1.EEA_TIPDOC,EEA1.R_E_C_N_O_ FROM " + cTableEEA + " EEA1 WHERE EEA1.EEA_TIPDOC = '1-Fax' "
   cQryEEA += " AND EEA1.EEA_COD  = (SELECT EEA2.EEA_COD FROM " + cTableEEA + " EEA2 WHERE EEA2.EEA_COD=EEA1.EEA_COD AND EEA2.EEA_TIPDOC = '1-Carta' and D_E_L_E_T_ = ' ' and EEA1.EEA_FILIAL = EEA2.EEA_FILIAL) "
   cQryEEA += " AND EEA1.EEA_ATIVO <>'2' AND EEA1.D_E_L_E_T_ = ' ' "
   TcQuery cQryEEA Alias "TMPEEA" New

   TMPEEA->(DBGoTop())
   EEA->(DbSetOrder(1))
   While TMPEEA->(!Eof())
      IF EEA->(DBSEEK(cFilEEA + TMPEEA->EEA_COD + TMPEEA->EEA_TIPDOC))
         EEA->(RecLock("EEA", .F.))
         EEA->EEA_ATIVO := '2'
         EEA->(MsUnlock())
      EndIf
      TMPEEA->(DBSkip())
   Enddo

   TMPEEA->(DBCloseArea())

   //2o. Desativa os documentos não utilizados a mais de 6 meses respeitando a lista
   for i:=1 to len(aListArq)
      cListArq += "'" + aListArq[i] + "',"
   next

   cListArq := substr(cListArq,1,len(cListArq)-1)
   cListArq += ")"

   cQryEEA:= "SELECT Y0_CODRPT FROM " + cTableSY0
   cQryEEA += " WHERE D_E_L_E_T_ = ' ' AND Y0_FILIAL = '" + cFilSYA + "' AND Y0_DATA <= '" + dtos(dDataLimite) + "'"
   cQryEEA += " AND Y0_CODRPT IN" + cListArq
   cQryEEA:= ChangeQuery(cQryEEA)
   TcQuery cQryEEA Alias "TMPSY0" New
   TMPSY0->(DBGoTop())

   While TMPSY0->(!Eof())
      IF EEA->(DBSEEK(cFilSYA+TMPSY0->Y0_CODRPT))
         EEA->(RecLock("EEA", .F.))
         EEA->EEA_ATIVO := '2'
         EEA->(MsUnlock())
      EndIf
      TMPSY0->(DBSkip())
   EndDO
   TMPSY0->(DBCloseArea())

   cQryEEA := "SELECT DISTINCT Y0_CODRPT FROM " + cTableSY0 + " WHERE D_E_L_E_T_ = ' ' AND Y0_FILIAL = '" + cFilSYA + "'"
   cQryEEA:= ChangeQuery(cQryEEA)
   TcQuery cQryEEA Alias "TMPNOTIN" New
   TMPNOTIN->(DBGoTop())
   While TMPNOTIN->(!Eof())
      cListNotIn += "'" + RTRIM(TMPNOTIN->Y0_CODRPT) + "',"
      TMPNOTIN->(DBSkip())
   EndDo
   TMPNOTIN->(DBCloseArea())
   cListNotIn := substr(cListNotIn,1,len(cListNotIn)-1)
   cListNotIn += ")"

   if len(cListNotIn) > 1
      cQryUpd := "UPDATE " + cTableEEA + " SET EEA_ATIVO = '2' WHERE EEA_COD IN " + cListArq + " AND EEA_COD NOT IN " + cListNotIn

      if( TCSQLEXEC(cQryUpd) < 0 , MsgAlert("Erro na atualização dos documentos na tabela EEA. Erro: " +  TCSqlError(),"Atenção"), )
   EndIf

   // 3o. Atualiza os campos modelo padrao, modelo customizado e tipo modelo padrão conforme critérios no jira
   // script validado nos três bancos pelo query analyzer da Totvs
   // EEA_MODELO = Modelo padrão
   // EEA_ARQUIV = Modelo customizado
   cQryEEA := "SELECT EEA.EEA_COD, EEA.EEA_TIPDOC FROM " + cTableEEA + " EEA WHERE EEA.EEA_MODELO=' ' AND EEA.EEA_ARQUIV='AVGLTT.RPT' AND EEA.D_E_L_E_T_ = ' ' "

   TcQuery cQryEEA Alias "TMPEEAUPD" New

   TMPEEAUPD->(DBGoTop())

   While TMPEEAUPD->(!Eof())
      IF EEA->(DBSEEK(cFilEEA + TMPEEAUPD->EEA_COD + TMPEEAUPD->EEA_TIPDOC))
         EEA->(RecLock("EEA", .F.))
         EEA->EEA_MODELO := 'AVGLTT'
         EEA->EEA_ARQUIV = ''
         EEA->EEA_TIPMOD = '1'
         EEA->EEA_EDICAO = '1'
         EEA->(MsUnlock())
      EndIf
      TMPEEAUPD->(DBSkip())
   Enddo
   TMPEEAUPD->(DBCloseArea())

return nil

static function AtuModeloAPH()
   Local aDocs := {}
   Local nx, nw

   aadd(aDocs,{{"chaveEEA", avkey("37","EEA_COD")+avkey("2-Documento","EEA_TIPDOC") },{"EEA_MODELO","FATING"},{"EEA_TIPMOD","1"},{"EEA_ARQUIV",""},{"EEA_EDICAO","1"}})
   aadd(aDocs,{{"chaveEEA", avkey("38","EEA_COD")+avkey("2-Documento","EEA_TIPDOC") },{"EEA_MODELO","FATESP"},{"EEA_TIPMOD","1"},{"EEA_ARQUIV",""},{"EEA_EDICAO","1"}})
   aadd(aDocs,{{"chaveEEA", avkey("92","EEA_COD")+avkey("2-Documento","EEA_TIPDOC") },{"EEA_MODELO","PACKING"},{"EEA_TIPMOD","1"},{"EEA_ARQUIV",""},{"EEA_EDICAO","1"}})
   aadd(aDocs,{{"chaveEEA", avkey("95","EEA_COD")+avkey("2-Documento","EEA_TIPDOC") },{"EEA_MODELO","PROFING"},{"EEA_TIPMOD","1"},{"EEA_ARQUIV",""},{"EEA_EDICAO","1"}})

   for nx := 1 to len(aDocs)
      IF EEA->(DBSEEK(xfilial("EEA") + aDocs[nx][1][2] ))
         for nw := 2 to len(aDocs[nx])
            EEA->(RecLock("EEA", .F.))
            EEA->&(aDocs[nx][nw][1]) := aDocs[nx][nw][2]
            EEA->(MsUnlock())
         next
      EndIf
   next

return

/*
Funcao                     : UPDEEC007
Parametros                 : Objeto de update PAI
Retorno                    : Nenhum
Objetivos                  : Atualização de dicionários e helps
Autor       			   : Lucas Raminelli LRS
Data/Hora   			   : 13/10/2015
Data/Hora Ultima alteração :
Revisao                    :
Obs.                       :
*/
Function UPDEEC007(o)
Local aOrd := SaveOrd("SX3") , aOrdSXB := {}

o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_VALID"                                                              },2)
o:TableData('SX3'  ,{'EE9_UNPRC' ,StrTran(Upper(SX3->X3_VALID), "AP104GATPRECO()", "Ap104GatPreco(,.F.)") })

//LRS - 20/10/2015 - alteração no campo SC6
o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_USADO"},2)
o:TableData('SX3'  ,{'C6_OPC'    ,TODOS_MODULOS})

AjustaEEQ(o)  // GFP - 16/10/2015

//MCF - 02/09/2015 - Correção teste sistemico
o:TableStruct("SXB",{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"       ,"XB_DESCSPA"      ,"XB_DESCENG"   ,"XB_CONTEM"              ,"XB_WCONTEM"})
o:TableData("SXB"  ,{ "EEA"    , "1"     ,"01"    ,"DB"       ,"Atividades"      ,"Actividades"     ,"Activities"   ,'EEA'                    ,            })
o:TableData("SXB"  ,{ "EEA"    , "2"     ,"01"    ,"01"       ,"Codigo Atividade","Codigo Actividad","Activity Code",""                       ,            })
o:TableData("SXB"  ,{ "EEA"    , "4"     ,"01"    ,"01"       ,"Codigo"          ,"Codigo"          ,"Code"         ,"EEA->EEA_COD"           ,            })
o:TableData("SXB"  ,{ "EEA"    , "4"     ,"01"    ,"02"       ,"Titulo"          ,"Titulo"          ,"Title"        ,"EEA->EEA_TITULO"        ,            })
o:TableData("SXB"  ,{ "EEA"    , "5"     ,"01"    ,""         ,""                ,""                ,""             ,"EEA->EEA_COD"           ,            })
o:TableData("SXB"  ,{ "EEA"    , "6"     ,"01"    ,""         ,""                ,""                ,""             ,"#AP100FilEEA(cOcorre)"  ,            })

o:TableStruct('SX2',{'X2_CHAVE','X2_UNICO'                                                                     })
o:TableData  ('SX2',{"EEJ"     ,'EEJ_FILIAL+EEJ_PEDIDO+EEJ_OCORRE+EEJ_TIPOBC+EEJ_CODIGO+EEJ_AGENCI+EEJ_NUMCON' }) //LRS - 14/09/2017

o:TableStruct("SX7",{'X7_CAMPO'   ,'X7_SEQUENC','X7_REGRA'     ,'X7_CDOMIN'  ,'X7_TIPO' ,'X7_SEEK' ,'X7_ALIAS' ,'X7_ORDEM' ,'X7_CHAVE'                    ,'X7_CONDIC' ,'X7_PROPRI'})
o:TableData  ('SX7',{'EE7_IMPORT' ,'010'       ,'SA1->A1_NOME' ,'EE7_IMPODE' ,'P'       ,'S'       ,'SA1'      ,1          ,'xFilial("SA1")+M->EE7_IMPORT',            ,'S'        })

o:TableStruct("SX7",{'X7_CAMPO'   ,'X7_SEQUENC','X7_REGRA'        ,'X7_CDOMIN','X7_CONDIC'          })
o:TableData  ('SX7',{'EE7_IMPORT' ,'002'       ,'AP102ViaTrans()' ,'EE7_VIA'  ,'AP102ViaTrans(.T.)' })

o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_F3" ,"X3_VALID"                     ,"X3_TRIGGER","X3_CBOX","X3_CBOXSPA","X3_CBOXENG"},2)
o:TableData( "SX3", {"A2_ID_FBFN" ,"48"    ,"AC115ValCpo('A2_ID_FBFN')"    ,""          ,""       ,""          ,""          })

o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_ORDEM" },2)
o:TableData  ("SX3",{"EE7_IMPORT" ,"13"       })
o:TableData  ("SX3",{"EE7_IMLOJA" ,"14"       })
o:TableData  ("SX3",{"EE7_IMPODE" ,"15"       })
o:TableData  ("SX3",{"EE7_TABPRE" ,"16"       })
o:TableData  ("SX3",{"EE7_STTDES" ,"17"       })
o:TableData  ("SX3",{"EE7_MOTSIT" ,"18"       })
o:TableData  ("SX3",{"EE7_DSCMTS" ,"19"       })

o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_ORDEM" },2)
o:TableData  ("SX3",{"EEC_IMPORT" ,"11"       })
o:TableData  ("SX3",{"EEC_IMLOJA" ,"12"       })
o:TableData  ("SX3",{"EEC_IMPODE" ,"13"       })
o:TableData  ("SX3",{"EEC_STTDES" ,"14"       })
o:TableData  ("SX3",{"EEC_MOTSIT" ,"15"       })
o:TableData  ("SX3",{"EEC_DSCMTS" ,"16"       })

o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_VALID"                                   ,"X3_RELACAO"  ,"X3_BROWSE","X3_INIBRW"                ,"X3_CBOX"                                               },2)
o:TableData("SX3"  ,{"EE7_AMOSTR","PERTENCE('124').AND.AP100CRIT('EE7_AMOSTR')","'2'"         ,"N"        ,                           ,"1=Sim – Sem Faturamento;2=Não;4=Sim – Com Faturamento" })
o:TableData("SX3"  ,{"EE7_VM_AMO",                                             ,              ,"S"        ,"AP102IniBrw('EE7_AMOSTR')",                                                        })
o:TableData("SX3"  ,{"EEC_AMOSTR","PERTENCE('124').AND.AE100CRIT('EEC_AMOSTR')","'2'"         ,"N"        ,                           ,"1=Sim – Sem Faturamento;2=Não;4=Sim – Com Faturamento" })
o:TableData("SX3"  ,{"EEC_VM_AMO",                                             ,              ,"S"        ,"AP102IniBrw('EEC_AMOSTR')",                                                        })

o:TableStruct("SX7",{'X7_CAMPO'   ,'X7_SEQUENC','X7_CONDIC'      },1)
o:TableData  ('SX7',{'EE7_IMPORT' ,'008'       ,'AP102CondGat()' })
o:TableData  ('SX7',{'EEC_IMPORT' ,'008'       ,'AP102CondGat()' })

o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_VALID"      },2)
o:TableData  ("SX3",{"YE_MOEDA"   ,"At140ValInt()" })

o:TableStruct("SX6",{"X6_FIL"   ,"X6_VAR"     ,"X6_TIPO","X6_DESCRIC"                                     ,"X6_DSCSPA"                                      ,"X6_DSCENG"                                      ,"X6_DESC1"                                     ,"X6_DSCSPA1"                                   ,"X6_DSCENG1"                                   ,"X6_DESC2"                               ,"X6_DSCSPA2"                             ,"X6_DSCENG2"                              ,"X6_CONTEUD","X6_CONTSPA","X6_CONTENG","X6_PROPRI","X6_PYME"})
o:TableData("SX6"  ,{"  "       ,"MV_EEC0041" ,"L"      ,"Desabilita a pergunta se deseja vincular um"    ,"Desabilita a pergunta se deseja vincular um"    ,"Desabilita a pergunta se deseja vincular um"    ,"embarque a uma carta de crédito caso não haja","embarque a uma carta de crédito caso não haja","embarque a uma carta de crédito caso não haja","saldo disponível na carta de crédito"   ,"saldo disponível na carta de crédito"   ,"saldo disponível na carta de crédito"    ,".F."       ,".F."       ,".F."       ,".T."      ,"S"      })
o:TableData("SX6"  ,{"  "       ,"MV_EEC0042" ,"L"      ,"Permite a compensação dos embarques que possuam","Permite a compensação dos embarques que possuam","Permite a compensação dos embarques que possuam","adiantamento, valores .T. ou .F."             ,"adiantamento, valores .T. ou .F."             ,"adiantamento, valores .T. ou .F."             ,""                                       ,""                                       ,""                                        ,".F."       ,".F."       ,".F."       ,".T."      ,"S"      })
o:TableData("SX6"  ,{"  "       ,"MV_EEC0043" ,"L"      ,"Caso habilitado, cria um pedido de compras"     ,"Caso habilitado, cria um pedido de compras"     ,"Caso habilitado, cria um pedido de compras"     ,"para cada despesa nacional e desabilita a"    ,"para cada despesa nacional e desabilita a"    ,"criação de um titulo no financeiro."          ,"criação de um titulo no financeiro."    ,"criação de um titulo no financeiro."    ,"criação de um titulo no financeiro."     ,".F."       ,".F."       ,".F."       ,".T."      ,"S"      })
o:TableData("SX6"  ,{"  "       ,"MV_EEC0044" ,"C"      ,"Define a condição de pagamento padrão para"     ,"Define a condição de pagamento padrão para"     ,"Define a condição de pagamento padrão para"     ,"os pedidos de compras criados para as"        ,"os pedidos de compras criados para as"        ,"os pedidos de compras criados para as"        ,"despesas nacionais (módulo de compras).","despesas nacionais (módulo de compras).","despesas nacionais (módulo de compras)." ,""          ,""          ,""          ,".T."      ,"S"      })

o:TableStruct('SX3',{'X3_ARQUIVO','X3_ORDEM','X3_CAMPO'    ,'X3_TIPO','X3_TAMANHO','X3_DECIMAL','X3_TITULO','X3_TITSPA','X3_TITENG','X3_DESCRIC'       ,'X3_DESCSPA'       ,'X3_DESCENG'       ,'X3_PICTURE','X3_VALID','X3_USADO'     ,'X3_RELACAO','X3_F3','X3_NIVEL','X3_RESERV','X3_CHECK','X3_TRIGGER','X3_PROPRI','X3_BROWSE','X3_VISUAL','X3_CONTEXT','X3_OBRIGAT','X3_VLDUSER','X3_CBOX','X3_CBOXSPA','X3_CBOXENG','X3_PICTVAR','X3_WHEN','X3_INIBRW','X3_GRPSXG','X3_FOLDER','X3_PYME','X3_CONDSQL','X3_CHKSQL','X3_IDXSRV','X3_ORTOGRA','X3_IDXFLD'})
o:TableData("SX3"  ,{"EET"       ,"43"      ,"EET_PEDCOM"  ,"C"      ,6           ,0           ,"Ped.Com." ,"Ped.Com." ,"Ped.Com." ,"Pedido de Compras","Pedido de Compras","Pedido de Compras",""          ,""        , TODOS_MODULOS ,""          ,""     ,""        ,""         ,""        ,""          ,""         ,""         , "V"       ,""          ,""          ,""          ,""       ,""          ,""          ,""          ,""       ,""         ,""         ,""         ,""       ,""          ,""         ,""         ,""          ,""         })
//o:TableData("SX3"  ,{'SYB'       ,'62'      ,'YB_PRODUTO'  ,'C'      ,AVSX3("B1_COD",3) ,0     ,'Cod.Produto','Cod.Produto','Cod.Produto','Codigo do Produto','Codigo del Producto','Product Code','@!'     ,'ExistCpo("SB1")',TODOS_MODULOS,''     ,'PRT'  ,1         ,NOME+TIPO+TAM+DEC,''       ,''           ,''          ,'S'         ,'A'          ,'R'         ,''            ,''          ,''                             ,''          ,''          ,''           ,''        ,''          ,'030'       ,''          ,'S'        ,''          ,''         ,'S'        ,'N'        ,'N'       })

o:TableStruct("EYC",{"EYC_FILIAL"   ,"EYC_CODAC","EYC_CODINT","EYC_CODEVE","EYC_CODSRV","EYC_CONDIC"                },1)
o:TableData("EYC"  ,{xFilial("EYC") ,"015"      ,"001"       ,"001"       ,"012"       ,"!EasyGParam('MV_EEC0043',,.F.)" })
o:TableData("EYC"  ,{xFilial("EYC") ,"016"      ,"001"       ,"001"       ,"013"       ,"!EasyGParam('MV_EEC0043',,.F.)" })
o:TableData("EYC"  ,{xFilial("EYC") ,"015"      ,"001"       ,"002"       ,"017"       ,"EasyGParam('MV_EEC0043',,.F.)"  })
o:TableData("EYC"  ,{xFilial("EYC") ,"016"      ,"001"       ,"002"       ,"018"       ,"EasyGParam('MV_EEC0043',,.F.)"  })

//UE_CERT_ORI() //LGS-06/11/2015
   //NCF - Ajustes para rotina de câmbio com movimentação no exterior.
   o:TableStruct("SX3",{"X3_CAMPO"    ,"X3_WHEN"              },2)
   o:TableData("SX3"  ,{"EEQ_SOL"     ,"AF200W('EEQ_SOL')"      })
   o:TableData("SX3"  ,{"EEQ_DTNEGO"  ,"AF200W('EEQ_DTNEGO')"   })
   o:TableData("SX3"  ,{"EEQ_PGT"     ,"AF200W('EEQ_PGT')"      })
   o:TableData("SX3"  ,{"EEQ_TX"      ,"AF200W('EEQ_TX')"       })
   o:TableData("SX3"  ,{"EEQ_EQVL"    ,"AF200W('EEQ_EQVL')"     })
   o:TableData("SX3"  ,{"EEQ_DTCE"    ,"AF200W('EEQ_DTCE')"     })

   o:TableStruct("SX3",{"X3_CAMPO"    ,"X3_VALID"               },2)
   o:TableData("SX3"  ,{"EEQ_MODAL"   ,"AF200VALID('EEQ_MODAL')"  })
   o:TableData("SX3"  ,{"EEQ_DTCE"    ,"AF200VALID('EEQ_DTCE')"   })

   o:TableStruct("SX7",{"X7_CAMPO"   ,"X7_SEQUENC","X7_REGRA"                                                                                    ,"X7_CDOMIN" ,"X7_TIPO","X7_SEEK","X7_ALIAS","X7_ORDEM","X7_CHAVE","X7_CONDIC"                                ,"X7_PROPRI"},1)
   o:TableData("SX7"  ,{"EEQ_BCOEXT" ,"001"       ,'BCOAGE(M->EEQ_BCOEXT)'                                                                       ,            ,         ,         ,          ,          ,          ,                                           ,           }  )

   o:TableStruct("SIX",{"INDICE","ORDEM" ,"CHAVE"                                                                    ,"DESCRICAO"                                                           })
   o:TableData("SIX"  ,{"EES"   ,"1"     ,"EES_FILIAL+EES_PREEMB+EES_NRNF+EES_SERIE+EES_PEDIDO+EES_SEQUEN+EES_FATSEQ","Processo + Nota Fiscal + Serie + Pedido + Sequencia + Seq.It.NF.Fa " })

//MCF - 22/12/2015
o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_VALID"                             },2)
o:TableData("SX3"  ,{"EEC_CONSIG" ,"AE100CRIT('EEC_CONSIG')"              })
o:TableData("SX3"  ,{"EEC_COLOJA" ,"VAZIO() .OR. AE100CRIT('EEC_COLOJA')" })

o:TableStruct("SX3",{"X3_CAMPO"    ,"X3_ORDEM"  },2)
o:TableData("SX3"  ,{"EEC_FORNDE"  ,"32"        })
o:TableData("SX3"  ,{"EEC_CONSIG"  ,"33"        })
o:TableData("SX3"  ,{"EEC_COLOJA"  ,"34"        })
o:TableData("SX3"  ,{"EEC_CONSDE"  ,"35"        })
o:TableData("SX3"  ,{"EEC_RESPON"  ,"36"        })
o:TableData("SX3"  ,{"EEC_LICIMP"  ,"20"        })//LGS-02/02/2016
o:TableData("SX3"  ,{"EEC_CLIENT"  ,"21"        })
o:TableData("SX3"  ,{"EEC_DTLIMP"  ,"20"        })
o:TableData("SX3"  ,{"EEC_EXPORT"  ,"28"        })
o:TableData("SX3"  ,{"EEC_CLIEDE"  ,"27"        })

o:TableStruct("SX7",{"X7_CAMPO"   ,"X7_SEQUENC","X7_REGRA"       ,"X7_SEEK","X7_ALIAS","X7_ORDEM","X7_CHAVE","X7_CONDIC"            },1)
o:TableData("SX7"  ,{"EEC_CONSIG" ,"001"       ,'AE102ConLoja()' ,"N"      ,""        ,          ,""        ,"Empty(M->EEC_COLOJA)" }  )

//MCF - 29/12/2015
o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_GRPSXG" },2)
o:TableData("SX3"  ,{"EET_LOJAF" ,"002"       })

//LRS - 20/01/2016
o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_WHEN" },2)
o:TableData("SX3"  ,{"EY4_CODBOL" ,"Inclui"  })

o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_WHEN" },2)
o:TableData("SX3"  ,{"EY4_COD" ,"Inclui"  })

//MCF - 30/12/2015
o:TableStruct("SX3",{"X3_CAMPO" ,"X3_PICTURE" },2)
o:TableData("SX3"  ,{"EXL_EMFR" ,"@!"         })

//MCF - 26/02/2016
o:TableStruct("SX7",{"X7_CAMPO" ,"X7_SEQUENC" ,"X7_REGRA"                           })
o:TableData  ('SX7',{'EEQ_PGT'  ,'001'        ,'BUSCATAXA(M->EEQ_MOEDA,M->EEQ_PGT)' })

//MCF - 17/05/2016
//o:TableStruct("SX7",{"X7_CAMPO" ,"X7_SEQUENC" ,"X7_CONDIC"           })
//o:TableData  ('SX7',{'EEQ_TX'   ,'002'        ,'Type("lIsEmb")=="L"' })

RestOrd(aOrd,.T.)

//LRS - 27/01/2016
o:TableStruct("SXB",{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"    ,"XB_DESCSPA"    ,"XB_DESCENG" ,"XB_CONTEM"              ,"XB_WCONTEM"})
o:TableData  ("SXB",{"Y6B"     ,"3"      ,"01"    ,"01"       ,"Cadastra Novo","Incluye Nuevo" ,"Add New"    ,"01#SI101RE('EER',0,3)"  ,            })

   //LRS - 1/6/2016
   o:TableStruct('SXA',{'XA_ALIAS','XA_ORDEM','XA_DESCRIC'            ,'XA_DESCSPA','XA_DESCENG','XA_PROPRI'})
   o:TableData('SXA',  {'EXJ'    ,'7'        ,'Endereço Complementar ',""          ,""          ,'S'})
   /* NÃO PODE EXISTIR CRIAÇÃO DE CAMPO NO AVUPDATE02, A CRIAÇÃO DEVE SER EFETUADA ATRAVES DO SDFBRA.TXT
   o:TableStruct("SX3",{"X3_ARQUIVO","X3_ORDEM","X3_CAMPO"   ,"X3_TIPO","X3_TAMANHO","X3_DECIMAL","X3_TITULO"     ,"X3_TITSPA" ,"X3_TITENG" ,"X3_DESCRIC"               ,"X3_DESCSPA" ,"X3_DESCENG" ,"X3_PICTURE"   ,"X3_VALID"                                                             ,"X3_USADO"    ,"X3_RELACAO","X3_F3" ,"X3_NIVEL","X3_RESERV" ,"X3_CHECK","X3_TRIGGER","X3_PROPRI","X3_BROWSE","X3_VISUAL","X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER","X3_CBOX","X3_CBOXSPA","X3_CBOXENG","X3_PICTVAR","X3_WHEN","X3_INIBRW","X3_GRPSXG","X3_FOLDER","X3_PYME","X3_CONDSQL","X3_CHKSQL","X3_IDXSRV","X3_ORTOGRA","X3_IDXFLD","X3_TELA"})
   o:TableData("SX3"  ,{"EXJ"       ,"14"      ,"EXJ_END"    ,"C"      ,40          ,0           ,"Endereço"      ,""          ,""          ,"Endereço do cliente"      ,""           ,""           , "@!"          ,""                                                                     ,TODOS_MODULOS ,""          ,""      ,0         ,USO         ,""        ,""          ,""         ,"N"        ,""         ,""          ,"N"         ,""          ,""       ,""          ,""          ,""          ,""       ,""         ,""         ,"7"        ,"N"      ,            ,           ,"N"        ,"N"         ,"N"        ,         })
   o:TableData("SX3"  ,{"EXJ"       ,"15"      ,"EXJ_BAIRRO" ,"C"      ,30          ,0           ,"Bairro"        ,""          ,""          ,"Bairro do cliente"        ,""           ,""           , "@!"          ,""                                                                     ,TODOS_MODULOS ,""          ,""      ,0         ,USO         ,""        ,""          ,""         ,"N"        ,""         ,""          ,"N"         ,""          ,""       ,""          ,""          ,""          ,""       ,""         ,""         ,"7"        ,"N"      ,            ,           ,"N"        ,"N"         ,"N"        ,         })
   o:TableData("SX3"  ,{"EXJ"       ,"16"      ,"EXJ_COD_ES" ,"C"      ,2           ,0           ,"Cd. Estado"    ,""          ,""          ,"Cod Estado do cliente "   ,""           ,""           , "@!"          ,'ExistCpo("SX5","12"+M->EXJ_COD_ES)'                                   ,TODOS_MODULOS ,""          ,"12"    ,0         ,USO         ,""        ,"S"         ,""         ,"N"        ,""         ,""          ,"N"         ,""          ,""       ,""          ,""          ,""          ,""       ,""         ,"010"      ,"7"        ,"N"      ,            ,           ,"N"        ,"N"         ,"N"        ,         })
   o:TableData("SX3"  ,{"EXJ"       ,"17"      ,"EXJ_EST"    ,"C"      ,30          ,0           ,"Estado"        ,""          ,""          ,"Estado do cliente "       ,""           ,""           , "@!"          ,""                                                                     ,TODOS_MODULOS ,""          ,""      ,0         ,USO         ,""        ,""          ,""         ,"N"        ,""         ,""          ,"N"         ,""          ,""       ,""          ,""          ,""          ,""       ,""         ,""         ,"7"        ,"N"      ,            ,           ,"N"        ,"N"         ,"N"        ,         })
   o:TableData("SX3"  ,{"EXJ"       ,"18"      ,"EXJ_COD_MU" ,"C"      ,5           ,0           ,"Cd. Municipio" ,""          ,""          ,"Código do Municipio"      ,""           ,""           , "@99999"      ,'ExistCpo("CC2",M->EXJ_COD_ES+M->EXJ_COD_MU)'                          ,TODOS_MODULOS ,""          ,"CC2SA1",0         ,USO         ,""        ,"S"         ,""         ,"N"        ,""         ,""          ,"N"         ,""          ,""       ,""          ,""          ,""          ,""       ,""         ,""         ,"7"        ,"N"      ,            ,           ,"N"        ,"N"         ,"N"        ,         })
   o:TableData("SX3"  ,{"EXJ"       ,"19"      ,"EXJ_MUN"    ,"C"      ,60          ,0           ,"Municipio"     ,""          ,""          ,"Municipio do cliente"     ,""           ,""           , "@!"          ,""                                                                     ,TODOS_MODULOS ,""          ,""      ,0         ,USO         ,""        ,""          ,""         ,"N"        ,""         ,""          ,"N"         ,""          ,""       ,""          ,""          ,""          ,""       ,""         ,""         ,"7"        ,"N"      ,            ,           ,"N"        ,"N"         ,"N"        ,         })
   o:TableData("SX3"  ,{"EXJ"       ,"20"      ,"EXJ_CEP"    ,"C"      ,8           ,0           ,"CEP"           ,""          ,""          ,"Cod Enderecamento Postal ",""           ,""           , "@R 99999-999","A030Cep()"                                                            ,TODOS_MODULOS ,""          ,""      ,0         ,USO         ,""        ,""          ,""         ,"N"        ,""         ,""          ,"N"         ,""          ,""       ,""          ,""          ,""          ,""       ,""         ,""         ,"7"        ,"N"      ,            ,           ,"N"        ,"N"         ,"N"        ,         })

   aAdd(o:aHelpProb,{"EXJ_END",    {"Endereço do cliente."}})
   aAdd(o:aHelpProb,{"EXJ_BAIRRO", {"Bairro do cliente."}})
   aAdd(o:aHelpProb,{"EXJ_COD_MU", {"Código do Municipio."}})
   aAdd(o:aHelpProb,{"EXJ_MUN",    {"Municipio do cliente."}})
   aAdd(o:aHelpProb,{"EXJ_CEP",    {"Código de endereçamento postal do cliente."}})
   aAdd(o:aHelpProb,{"EXJ_COD_ES", {"Código do Estado do cliente."}})
   aAdd(o:aHelpProb,{"EXJ_EST",    {"Estado do cliente."}})
   */
   o:TableStruct("SX7",{"X7_CAMPO"  ,"X7_SEQUENC","X7_REGRA"     ,"X7_CDOMIN" ,"X7_TIPO","X7_SEEK","X7_ALIAS","X7_ORDEM","X7_CHAVE"                                   ,"X7_CONDIC" ,"X7_PROPRI"})
   o:TableData("SX7"  ,{"EXJ_COD_MU","001"       ,"CC2->CC2_MUN" ,"EXJ_MUN"   ,"P"      ,"S"      ,"CC2"     ,"1"       ,"xFilial('CC2')+M->EXJ_COD_ES+M->EXJ_COD_MU ",""          ,"S"        })

   o:TableStruct("SX7",{"X7_CAMPO"  ,"X7_SEQUENC","X7_REGRA"   ,"X7_CDOMIN" ,"X7_TIPO","X7_SEEK","X7_ALIAS","X7_ORDEM","X7_CHAVE"                           ,"X7_CONDIC" ,"X7_PROPRI"})
   o:TableData("SX7"  ,{"EXJ_COD_ES","001"       ,"X5DESCRI()" ,"EXJ_EST"   ,"P"      ,"S"      ,"SX5"     ,"1"       ,"xFilial('SX5')+'12'+M->EXJ_COD_ES  ",""          ,"S"        })


   o:TableStruct("SX3",{"X3_CAMPO"   , "X3_USADO", "X3_BROWSE"},2) //LGS-10/06/2016
   o:TableData( "SX3", {"EEX_FILIAL" , TODOS_AVG , "S"        }  )
   o:TableData( "SX3", {"EEX_PREEMB" , TODOS_AVG , "S"        }  )
   o:TableData( "SX3", {"EEX_NUM"    , TODOS_AVG , "N"        }  )
   o:TableData( "SX3", {"EEX_DATA"   , TODOS_AVG , "N"        }  )
   o:TableData( "SX3", {"EEX_CNPJ"   , TODOS_AVG , "S"        }  )
   o:TableData( "SX3", {"EEX_CNPJ_R" , TODOS_AVG , "N"        }  )
   o:TableData( "SX3", {"EEX_RLFJ"   , TODOS_AVG , "N"        }  )
   o:TableData( "SX3", {"EEX_VIAINT" , TODOS_AVG , "S"        }  )
   o:TableData( "SX3", {"EEX_DVIAIN" , TODOS_AVG , "S"        }  )
   o:TableData( "SX3", {"EEX_PESLIQ" , TODOS_AVG , "S"        }  )
   o:TableData( "SX3", {"EEX_PESBRU" , TODOS_AVG , "S"        }  )
   o:TableData( "SX3", {"EEX_TOTCV"  , TODOS_AVG , "S"        }  )

// NCF - 29/04/2016 - Verifica se está ativada a integração do SIGAEEC com o ERP Externo via mensagem única
//                    Estas alterações só devem ser existir no dicionário do ambiente, ou seja, não constam no ATUSX.
If EasyGParam("MV_EECI010",,.F.)

   o:TableStruct("SIX",{"INDICE","ORDEM" ,"CHAVE"                ,"DESCRICAO","DESCSPA","DESCENG","PROPRI"})
   o:TableData("SIX"  ,{"SAH"   ,"2"     ,"AH_FILIAL+AH_CODERP"  ,"Cod.ERP"  ,"Cod.ERP","Cod.ERP",""      })

   o:TableStruct("SX3",{"X3_ARQUIVO","X3_CAMPO"  ,"X3_RESERV"   ,"X3_OBRIGAT"},2)
   o:TableData("SX3"  ,{"SAH"       ,"AH_COD_SIS",TAM           ,"N"})

   o:TableStruct("SX3",{"X3_ARQUIVO","X3_CAMPO"  ,"X3_WHEN"})
   o:TableData("SX3"  ,{"EEQ"       ,"EEQ_HVCT"  ,".F."})

   o:TableStruct("SX7",{"X7_CAMPO"    , "X7_SEQUENC","X7_CONDIC"})
   o:TableData("SX7"  ,{"EEQ_CODEMP"  ,"001"        ,'!AVFLAGS("EEC_LOGIX")'})
   o:TableData("SX7"  ,{"EEQ_CODEMP"  ,"002"        ,'!AVFLAGS("EEC_LOGIX")'})

   o:TableStruct("SX7",{"X7_CAMPO"   ,"X7_SEQUENC","X7_REGRA"                                                                                    ,"X7_CDOMIN" ,"X7_TIPO","X7_SEEK","X7_ALIAS","X7_ORDEM","X7_CHAVE","X7_CONDIC"                                ,"X7_PROPRI"},1)
   //THTS - 21/07/2017 - nopado: a regra adicionada existia no fonte EECAF300, o que matava esta regra que o update adicionava.
   //o:TableData("SX7",{"EEQ_TX"     ,"001"       ,"M->EEQ_TX*IF(Type('nTotFFC')='N',nTotFFC,M->EEQ_VLFCAM)"                                     ,'EEQ_EQVL'  ,'P'      ,'N'      ,          ,          ,          ,' '                                        ,"S"        }  )
   //o:TableData("SX7"  ,{"EEQ_TX"     ,"001"       ,"M->EEQ_TX*IF(Type('nTotFFC')='N',nTotFFC,M->EEQ_VL)"                                         ,'EEQ_EQVL'  ,'P'      ,'N'      ,          ,          ,          ,' '                                        ,"S"        }  )
   //--
   o:TableData("SX7"  ,{"EEQ_TX"     ,"002"       ,"0"                                                                                           ,"EEQ_EQVL"  ,"P"      ,"N"      ,""        ,"0"       ,""        ,"Empty(M->EEQ_TX)"                         ,"S"        }  )
   o:TableData("SX7"  ,{"EEQ_TX"     ,"003"       ,"M->EEQ_TX*M->EEQ_VM_REC"                                                                     ,"EEQ_EQVL"  ,"P"      ,"N"      ,''        ,''        ,          ,'IsInCallStack("EECAF500")'                ,"S"        }  )
   o:TableData("SX7"  ,{"EEQ_VL"     ,"001"       ,"M->EEQ_VL-M->EEQ_DESCON"                                                                     ,'EEQ_VM_REC','P'      ,'N'      ,          ,          ,          ,'!lFinanciamento'                          ,"S"        }  )
   o:TableData("SX7"  ,{"EEQ_VL"     ,"002"       ,"M->EEQ_TX*IF(Type('nTotFFC')='N',nTotFFC,M->EEQ_VLFCAM)"                                     ,'EEQ_EQVL'  ,'P'      ,'N'      ,          ,          ,          ,'Type("lIsEmb")="U" .and. !lFinanciamento' ,"S"        }  )
   o:TableData("SX7"  ,{"EEQ_DESCON" ,"001"       ,"M->EEQ_VL-M->EEQ_DESCON"                                                                     ,'EEQ_VM_REC','P'      ,'N'      ,          ,          ,          ,'Type("lTelaVincula")="U".Or.lTelaVincula' ,"S"        }  )
   
   o:TableStruct("SX3",{"X3_ARQUIVO","X3_CAMPO"  ,"X3_VALID"},2)
   o:TableData(  "SX3",{"SY5"       ,"Y5_BANCO"  ,""        })

   o:TableStruct("SX3",{"X3_ARQUIVO","X3_CAMPO"  ,"X3_VALID"                                                                               })
   o:TableData(  "SX3",{"SYE"       ,"YE_MOEDA"  ,"AvgExistCpo('SYF',M->YE_MOEDA) .AND. ExistChav('SYE',DTOS(M->YE_DATA)+M->YE_MOEDA)"     })

   o:TableStruct("SX3",{"X3_ARQUIVO","X3_CAMPO"   ,"X3_TRIGGER","X3_VALID"                                        })
   o:TableData("SX3"  ,{"EES"       ,"EES_QTDDEV" , "S"        , "If(FindFunction('NF400Valid'),NF400Valid(),.T.)"})

   o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_RESERV", "X3_OBRIGAT" },2)
   o:TableData("SX3"  ,{"EEE_DCRED"  ,           , "N"          })

   o:TableStruct("SX6",{"X6_FIL"       ,"X6_VAR"     ,"X6_TIPO","X6_DESCRIC"                                        ,"X6_DESC1"                                                              ,"X6_DESC2"                                              ,"X6_DSCSPA2","X6_DSCENG2","X6_CONTEUD","X6_CONTSPA","X6_CONTENG","X6_PROPRI","X6_PYME"})
   o:TableData("SX6"  ,{xFilial("SX6") ,"MV_EEC0048," ,"L"      ,"Determina se será controlada a geração de eventos" ,"contábeis de embarque em transito para a despesa "                    ,"de comissão em conta gráfica"                          ,""          ,""          ,".T."       ,".T."       ,".T."       ,"S"        ,"N"      })
   o:TableData("SX6"  ,{xFilial("SX6") ,"MV_EEC0049," ,"L"      ,"Indica se serão realizadas integrações contábeis " ,"da comissão conta gráfica via EAI durante a"                          ,"manutenção de embarque e liquidação de câmbio "        ,""          ,""          ,".T."       ,".T."       ,".T."       ,"S"        ,"N"      })

   o:TableStruct("SX7",{"X7_CAMPO"    , "X7_SEQUENC","X7_CONDIC"})
   o:TableData("SX7"  ,{"EE8_COD_I"   ,"002"        ,"Empty(M->EE8_EMBAL1)"})
   o:TableData("SX7"  ,{"EE8_COD_I"   ,"004"        ,"Empty(M->EE8_QE)"    })

   o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_USADO"},2)
   o:TableData(  "SX3",{"EE8_DSCQUA",NAO_USADO})

   //o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_TAMANHO","X3_DECIMAL" ,"X3_PICTURE"        },2)
   //o:TableData("SX3"  ,{"EYH_QTDEMB",14           ,3           ,"@E 99,999,999.999" })
   //o:TableData("SX3"  ,{"EYH_RELSUP",14           ,3           ,"@E 99,999,999.999" })
   //o:TableData("SX3"  ,{"A1_TEL"    ,20           ,0           ,"" })
   //o:TableData("SX3"  ,{"A1_FAX"    ,20           ,0           ,"" })

   //o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_TAMANHO" ,"X3_DECIMAL" ,"X3_PICTURE", "X3_RESERV" },2)
   //o:TableData("SX3"  ,{"EEM_SERIE" , 3           ,0            ,"@!"        , TAM+DEC     })   //ocasiona erro no UPDSISTR

   //o:TableStruct("SX3",{"X3_ARQUIVO","X3_CAMPO","X3_TAMANHO"})
   //o:TableData(  "SX3",{"SA6"       ,"A6_DVAGE","2"         })
   //o:TableData(  "SX3",{"SA6"       ,"A6_DVCTA","2"         })
   o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_BROWSE"},2)
   o:TableData("SX3"  ,{"EF3_SEQBX" ,"S"        })                     //NCF - 20/06/2016 - EFF x LOGIX

   o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_RESERV"},2)
   o:TableData("SX3"  ,{"EYH_QTDEMB",TAM+DEC    })
   o:TableData("SX3"  ,{"EYH_RELSUP",TAM+DEC    })
   o:TableData("SX3"  ,{"A1_TEL"    ,TAM+DEC    })
   o:TableData("SX3"  ,{"A1_FAX"    ,TAM+DEC    })
   o:TableData("SX3"  ,{"A6_DVAGE"  ,TAM+DEC    })
   o:TableData("SX3"  ,{"A6_DVCTA"  ,TAM+DEC    })

   o:TableStruct("SX3",{"X3_ARQUIVO","X3_CAMPO" ,"X3_VISUAL"})
   o:TableData(  "SX3",{"EES"       ,"EES_COD_I","A"        })

   o:TableStruct("SX3",{"X3_ARQUIVO","X3_CAMPO"    ,"X3_FOLDER"},2)
   o:TableData(  "SX3",{"EE7"       ,"EE7_DTSLAP"  ,"1"        })
   o:TableData(  "SX3",{"EE7"       ,"EE7_DTAPPE"  ,"1"        })

   o:TableStruct("SX5",{"X5_FILIAL"     ,"X5_TABELA","X5_CHAVE","X5_DESCRI"                           ,"X5_DESCSPA"                        ,"X5_DESCENG"                        })
   o:TableData(  "SX5",{xFilial("SX5")  , "YC"      , "N     " ,"Aguardando Aprovação da Proforma"    ,"Aguardando Aprovação da Proforma"  ,"Aguardando Aprovação da Proforma"  })
   o:TableData(  "SX5",{xFilial("SX5")  , "YC"      , "O     " ,"Proforma Aprovada"                   ,"Proforma Aprovada"                 ,"Proforma Aprovada"                 })
   o:TableData(  "SX5",{xFilial("SX5")  , "YC"      , "P     " ,"Proforma em Edição"                  ,"Proforma em Edição"                ,"Proforma em Edição"                })
   o:TableData(  "SX5",{xFilial("SX5")  , "YC"      , "Q     " ,"Processo devolvido"                  ,"Processo devolvido"                ,"Processo devolvido"                })

   o:TableData("MENU",{"SIGAEFF"  ,"EFFEX103",{"Miscelanea"}    ,""                ,{"Lctos para Contab"      ,"Lctos para Contab"       ,"Lctos para Contab"}      ,"1" ,{"EF1"}       ,"xxxxxxxxxx","0"  })
   o:TableData("MENU",{"SIGAEFF"  ,"EFFEX104",{"Miscelanea"}    ,""                ,{"Cancelam. Contab"       ,"Cancelam. Contab"        ,"Cancelam. Contab"}       ,"1" ,{"EF1","EF3"} ,"xxxxxxxxxx","0"  })
   o:TableData("MENU",{"SIGAEEC"  ,"EECREG85",{"Miscelanea"}    ,""                ,{"Registro 85"            ,"Registro 85"             ,"Registro 85"}            ,"1" ,{"EEC"}       ,"xxxxxxxxxx","0"  })
   o:TableData("MENU",{"SIGAEEC"  ,"EECNF400",{"Atualizações"}  ,""                ,{"Notas Fiscais de Saida" ,"Notas Fiscais de Saida"  ,"Notas Fiscais de Saida"} ,"1" ,{"EEM","EES"} ,"xxxxxxxxxx","0"  })
   o:TableData("MENU",{"SIGAEEC"  ,"EECLC500",{"Miscelanea"}    ,""                ,{"Lanc.Contab.Comissão CG","Lanc.Contab.Comissão CG" ,"Lanc.Contab.Comissão CG"},"1" ,{"ECF"}       ,"xxxxxxxxxx","0"  })
EndIf
//LRS - 06/06/2016
o:TableStruct("SX7",{"X7_CAMPO"  ,"X7_SEQUENC","X7_REGRA"                                                                                 ,"X7_CDOMIN" ,"X7_TIPO","X7_SEEK","X7_ALIAS","X7_ORDEM","X7_CHAVE"                   ,"X7_CONDIC"   ,"X7_PROPRI"})
o:TableData("SX7"  ,{"B1_POSIPI" ,"002"       ,"IF (SYD->YD_ANUENTE <> '' .OR. SYD->YD_ANUENTE == '2',SYD->YD_ANUENTE, M->B1_ANUENTE)"    ,"B1_ANUENTE","P"      ,"S"      ,"SYD"     ,"1"       ,'xFilial("SYD")+M->B1_POSIPI',""            ,"S"        })

o:TableStruct("SX1",{"X1_GRUPO"  ,"X1_ORDEM"  ,"X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_TIPO" ,"X1_TAMANHO","X1_VAR01","X1_DECIMAL","X1_GSC", "X1_DEF01", "X1_DEF02", "X1_DEF03"})
o:TableData("SX1"  ,{"EI100A"    ,"02"        ,"Regional?" ,"Regional?","Regional?" ,"C"       ,2           ,"MV_PAR02", 0          ,"C"	 , ""        , ""        , ""        })
o:TableData("SX1"  ,{"EI100A"    ,"03"        ,"Idioma?"   ,"Idioma?"  ,"Idioma?"   ,"C"       ,2           ,"MV_PAR03", 0          ,"C"	 , "EN"      , "PT"      , "ES"      })

//LRS - 01/12/2016
o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_VALID" },2)
o:TableData  ("SX3",{"EXL_FINTFR" ,'Vazio() .Or. ExistCpo("SA2",M->EXL_FINTFR+AllTrim(M->EXL_FLOJFR),,,,!EMPTY(M->EXL_FLOJFR)) .AND. DespIntVld()'       })
o:TableData  ("SX3",{"EXL_FINTSE" ,'Vazio() .Or. ExistCpo("SA2",M->EXL_FINTSE+AllTrim(M->EXL_FLOJSE),,,,!EMPTY(M->EXL_FLOJSE)) .AND. DespIntVld()'      })
o:TableData  ("SX3",{"EXL_FINTFA" ,'Vazio() .Or. ExistCpo("SA2",M->EXL_FINTFA+AllTrim(M->EXL_FLOJFA),,,,!EMPTY(M->EXL_FLOJFA)) .AND. DespIntVld()'      })

o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_TITULO"    },2)
o:TableData  ("SX3",{"EXL_FLOJFR" ,'Loj.Fre.Int.' })
o:TableData  ("SX3",{"EXL_FLOJSE" ,'Loj.Fre.Int.' })
o:TableData  ("SX3",{"EXL_FLOJFA" ,'Loj.Fre.Int.' })

//MFR - 08/02/2017
o:TableStruct("SX3"  ,{"X3_CAMPO" ,"X3_USADO", "X3_RESERV"},2)
o:TableData  ("SX3"  ,{"EE8_TES"   , TODOS_MODULOS, USO+OBRIGAT})
o:TableData  ("SX3"  ,{"EE8_CF"   , TODOS_MODULOS, USO+OBRIGAT})

//THTS - 20/07/2017
o:TableStruct("SXB",{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"       	 ,"XB_DESCSPA"      		,"XB_DESCENG"   			,"XB_CONTEM"       ,"XB_WCONTEM"})
o:TableData("SXB"  ,{ "ATOCON" , "1"     ,"01"    ,"RE"       ,"Ato Concessorio"		 ,"Ato Concessorio"		,"Ato Concessorio" 		,""                ,                })
o:TableData("SXB"  ,{ "ATOCON" , "2"     ,"01"    ,"01"       ,""                	 ,""                		,""             			,"XBEECAE100()"    ,            })
o:TableData("SXB"  ,{ "ATOCON" , "5"     ,"01"    ,""         ,""                	 ,""                		,""             			,"cRetorno"        ,            })

o:TableStruct("SX3"  ,{"X3_CAMPO"   ,"X3_F3" },2)
o:TableData  ("SX3"  ,{"EE9_ATOCON" ,"ATOCON"})

//CEO - 02/03/2018
o:TableStruct("SX3",{"X3_CAMPO", "X3_RESERV"},2)
o:TableData  ("SX3",{"EXJ_END", TAM})

//CEO - 08/05/2018
o:TableStruct("SX3",{"X3_CAMPO", "X3_VALID"},2)
o:TableData  ("SX3",{"EE8_RESERV", 'Vazio() .or. EECVLEE8("EE8_RESERV")'})

Return Nil

//WFS - 27/06/2017 - chamado por UPDESS
Function AjustaEEQ(o)  // GFP - 16/10/2015

o:TableStruct("SX7",{'X7_CAMPO'  ,'X7_SEQUENC'  , 'X7_REGRA'               ,'X7_CDOMIN'  ,'X7_TIPO' ,'X7_SEEK'  ,'X7_ALIAS' , 'X7_ORDEM' , 'X7_CHAVE'                       , 'X7_CONDIC'                               ,'X7_PROPRI'},1)
//THTS - 21/07/2017 - nopado: a regra adicionada existia no fonte EECAF300, o que matava esta regra que o update adicionava.
//o:TableData("SX7",{ 'EEQ_TX' , '001' , 'M->EEQ_TX*IF(TYPE("nTOTFFC")="N",nTOTFFC,M->EEQ_VM_REC)' , 'EEQ_EQVL' , 'P' , 'N' , '' , '' ,, '!lFinanciamento' , 'S'})
//o:TableData("SX7"  ,{ "EEQ_TX" , "001" , "M->EEQ_TX*IF(Type('nTotFFC')='N',nTotFFC,M->EEQ_VL)"                                         ,'EEQ_EQVL'  ,'P'      ,'N'      ,          ,          ,          ,' '                                        ,"S"        }  )
//o:TableData("SX7"  ,{ 'EEQ_TX' , '002' , 'M->EEQ_TX*M->EEQ_VLFCAM' , 'EEQ_EQVL' , 'P' , '' , '' , '' ,, 'Type("lIsEmb")=="U"' , 'S'})
o:TableData("SX7"  ,{ 'EEQ_TX' , '003' , 'M->EEQ_TX*M->EEQ_VM_REC' , 'EEQ_EQVL' , 'P' , 'N' , '' , '' ,, 'IsInCallStack("EECAF500")' , 'S'})

o:TableData("SX7"  ,{"EEQ_PGT" ,"001"  ,'BUSCATAXA(EEC->EEC_MOEDA,M->EEQ_PGT)'                                                        ,'EEQ_TX'    ,'P'      ,'N'      ,          ,          ,          ,'Type("lIsEmb")="L" .And. lIsEmb = .T.'    ,"S"        }  )
o:TableData("SX7"  ,{"EEQ_PGT" ,"002"  ,'BuscaTaxa(Posicione("EXJ",1,xFilial("EXJ")+SA1->A1_COD+SA1->A1_LOJA,"EXJ_MOEDA"),M->EEQ_PGT)','EEQ_TX'    ,'P'      ,'N'      ,          ,          ,          ,'Type("cTipoCad")="C" .AND. cTipoCad="I"'  ,"S"        }  )
o:TableData("SX7"  ,{"EEQ_PGT" ,"003"  ,'BUSCATAXA(EE7->EE7_MOEDA,M->EEQ_PGT)'                                                        ,'EEQ_TX'    ,'P'      ,'N'      ,          ,          ,          ,'Type("lIsPed")="L" .AND. lIsPed = .T.'    ,"S"        }  )
o:TableData("SX7"  ,{"EEQ_PGT" ,"004"  ,"M->EEQ_TX*IF(Type('nTotFFC')='N',nTotFFC,M->EEQ_VLFCAM)"                                     ,'EEQ_EQVL'  ,'P'      ,'N'      ,          ,          ,          ,'TYPE("LISEMB")="U"'                       ,"S"        }  )
o:TableData("SX7"  ,{"EEQ_PGT" ,"005"  ,"M->EEQ_TX*IF(Type('nTotFFC')='N',nTotFFC,M->EEQ_VLFCAM)"                                     ,'EEQ_EQVL'  ,'P'      ,'N'      ,          ,          ,          ,'TYPE("LISEMB")<>"U" .AND. LISEMB'         ,"S"        }  )
o:TableData("SX7"  ,{"EEQ_PGT" ,"006"  ,"0"                                                                                           ,"EEQ_TX"    ,"P"      ,"N"      ,""        ,"0"       ,""        ,"Empty(M->EEQ_PGT)"                        ,"S"        }  )
o:TableData("SX7"  ,{"EEQ_PGT" ,"007"  ,"0"                                                                                           ,"EEQ_EQVL"  ,"P"      ,"N"      ,""        ,"0"       ,""        ,"Empty(M->EEQ_PGT)"                        ,"S"        }  )

Return Nil
/*
Funcao                     : UPDEEC014
Parametros                 : Objeto de update PAI
Retorno                    : Nenhum
Objetivos                  : Atualização de dicionários e helps
Autor       			      : Lucas Raminelli LRS
Data/Hora   			      : 10/11/2016
Data/Hora Ultima alteração :
Revisao                    :
Obs.                       :
*/
Function UPDEEC014(o)


Local n0052 := 1

//LRS - 10/11/2016 - NOPADO POR GFP - 30/11/2016 - AvUpdate02 não pode conter criação de campos SX3.
//Update implementa o campo EYJ_CODFIE, para registrar o ID da declaração de origem na integração com o portal ECOOL.
//o:TableStruct('SX3',{'X3_ARQUIVO','X3_ORDEM','X3_CAMPO'    ,'X3_TIPO','X3_TAMANHO','X3_DECIMAL','X3_TITULO' ,'X3_TITSPA'   ,'X3_TITENG','X3_DESCRIC','X3_DESCSPA','X3_DESCENG','X3_PICTURE','X3_VALID','X3_USADO'     ,'X3_RELACAO','X3_F3','X3_NIVEL','X3_RESERV','X3_CHECK','X3_TRIGGER','X3_PROPRI','X3_BROWSE','X3_VISUAL','X3_CONTEXT','X3_OBRIGAT','X3_VLDUSER','X3_CBOX','X3_CBOXSPA','X3_CBOXENG','X3_PICTVAR','X3_WHEN','X3_INIBRW','X3_GRPSXG','X3_FOLDER','X3_PYME','X3_CONDSQL','X3_CHKSQL','X3_IDXSRV','X3_ORTOGRA','X3_IDXFLD'})
//o:TableData("SX3"  ,{"EYJ"       , "99"     , "EYJ_CODFIE" , "C"      , 20         , 0          , "Cod.FIESP" ,"Cod.FIESP" ,"Cod.FIESP","Cod.FIESP" ,"Cod.FIESP" ,"Cod.FIESP" ,            ,          , TODOS_MODULOS ,            ,       ,          ,           ,          ,            ,           ,           ,"A"        ,"R"         ,            ,            ,         ,            ,            ,            ,         ,           ,           ,           ,         ,            ,           ,           ,            ,           })

//LRS - 01/12/2016
o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_VALID" },2)
o:TableData  ("SX3",{"EXL_FINTFR" ,'Vazio() .Or. ExistCpo("SA2",M->EXL_FINTFR+AllTrim(M->EXL_FLOJFR),,,,!EMPTY(M->EXL_FLOJFR)) .AND. DespIntVld()'       })
o:TableData  ("SX3",{"EXL_FINTSE" ,'Vazio() .Or. ExistCpo("SA2",M->EXL_FINTSE+AllTrim(M->EXL_FLOJSE),,,,!EMPTY(M->EXL_FLOJSE)) .AND. DespIntVld()'      })
o:TableData  ("SX3",{"EXL_FINTFA" ,'Vazio() .Or. ExistCpo("SA2",M->EXL_FINTFA+AllTrim(M->EXL_FLOJFA),,,,!EMPTY(M->EXL_FLOJFA)) .AND. DespIntVld()'      })

o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_TITULO"    },2)
o:TableData  ("SX3",{"EXL_FLOJFR" ,'Loj.Fre.Int.' })
o:TableData  ("SX3",{"EXL_FLOJSE" ,'Loj.Fre.Int.' })
o:TableData  ("SX3",{"EXL_FLOJFA" ,'Loj.Fre.Int.' })
/* migrado para avupdate02, para ser executada independente de versão
//MCF - Correção para versão 12.1.14 - Deletando digitação nota fiscal de remessa - Projeto Durli
If !NFRemNewStruct() //NCF - 17/03/2017 - Deve verificar se a utilização da nova rotina está ativada antes de atualizar a consulta(solução temporária até a homologação da nova consulta)
   //Limpa nova consulta
   o:TableStruct("SXB" ,{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"           ,"XB_DESCSPA"          ,"XB_DESCENG"          ,"XB_CONTEM"                 })
   o:DelTableData("SXB",{"EYY"     ,"1"      ,"01"    ,"DB"       ,""                    ,""                    ,""                    ,""                          })
   o:DelTableData("SXB",{"EYY"     ,"1"      ,"01"    ,"RE"       ,""                    ,""                    ,""                    ,""                          })
   o:DelTableData("SXB",{"EYY"     ,"2"      ,"01"    ,"01"       ,""                    ,""                    ,""                    ,""                          })
   o:DelTableData("SXB",{"EYY"     ,"4"      ,"01"    ,"01"       ,""                    ,""                    ,""                    ,""                          })
   o:DelTableData("SXB",{"EYY"     ,"4"      ,"01"    ,"02"       ,""                    ,""                    ,""                    ,""                          })
   o:DelTableData("SXB",{"EYY"     ,"4"      ,"01"    ,"03"       ,""                    ,""                    ,""                    ,""                          })
   o:DelTableData("SXB",{"EYY"     ,"4"      ,"01"    ,"04"       ,""                    ,""                    ,""                    ,""                          })
   o:DelTableData("SXB",{"EYY"     ,"5"      ,"01"    ,""         ,""                    ,""                    ,""                    ,""                          })
   o:DelTableData("SXB",{"EYY"     ,"5"      ,"02"    ,""         ,""                    ,""                    ,""                    ,""                          })
   o:DelTableData("SXB",{"EYY"     ,"5"      ,"03"    ,""         ,""                    ,""                    ,""                    ,""                          })
   o:DelTableData("SXB",{"EYY"     ,"5"      ,"04"    ,""         ,""                    ,""                    ,""                    ,""                          })
   //Restaura a antiga consulta
   o:TableStruct("SXB" ,{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"              ,"XB_DESCSPA"            ,"XB_DESCENG"            ,"XB_CONTEM"                })
   o:TableData("SXB"   ,{"EYY"     ,"1"      ,"01"    ,"DB"       ,"N.F.s de Entrada"       ,"Fact. de Entrada"      ,"Receipt Invoices"      ,"SF1"                      })
   o:TableData("SXB"   ,{"EYY"     ,"2"      ,"01"    ,"01"       ,"Numero + Serie + For"   ,"Numero + Serie + Pro"  ,"Number+Series+Sup."    ,""                         })
   o:TableData("SXB"   ,{"EYY"     ,"4"      ,"01"    ,"01"       ,"Número"                 ,"Numero"                ,"Number"                ,"F1_DOC"                   })
   o:TableData("SXB"   ,{"EYY"     ,"4"      ,"01"    ,"02"       ,"Serie"                  ,"Serie"                 ,"Series"                ,"F1_SERIE"                 })
   o:TableData("SXB"   ,{"EYY"     ,"4"      ,"01"    ,"03"       ,"Fornecedor"             ,"Proveedor"             ,"Supplier"              ,"F1_FORNECE"               })
   o:TableData("SXB"   ,{"EYY"     ,"4"      ,"01"    ,"04"       ,"Loja"                   ,"Tienda"                ,"Unit"                  ,"F1_LOJA"                  })
   o:TableData("SXB"   ,{"EYY"     ,"5"      ,"01"    ,""         ,""                       ,""                      ,""                      ,"SF1->F1_DOC"              })
   o:TableData("SXB"   ,{"EYY"     ,"5"      ,"02"    ,""         ,""                       ,""                      ,""                      ,"SF1->F1_SERIE"            })
   o:TableData("SXB"   ,{"EYY"     ,"5"      ,"03"    ,""         ,""                       ,""                      ,""                      ,"SF1->F1_FORNECE"          })
   o:TableData("SXB"   ,{"EYY"     ,"5"      ,"04"    ,""         ,""                       ,""                      ,""                      ,"SF1->F1_LOJA"             })

Else
   //Limpa a antiga consulta
   o:TableStruct("SXB",{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA"}, 1)
   o:DelTableData("SXB" ,{"EYY"     ,"1"      ,"01"    ,"DB"       })
   o:DelTableData("SXB" ,{"EYY"     ,"2"      ,"01"    ,"01"       })
   o:DelTableData("SXB" ,{"EYY"     ,"4"      ,"01"    ,"01"       })
   o:DelTableData("SXB" ,{"EYY"     ,"4"      ,"01"    ,"02"       })
   o:DelTableData("SXB" ,{"EYY"     ,"4"      ,"01"    ,"03"       })
   o:DelTableData("SXB" ,{"EYY"     ,"4"      ,"01"    ,"04"       })
   o:DelTableData("SXB" ,{"EYY"     ,"5"      ,"01"    ,""         })
   o:DelTableData("SXB" ,{"EYY"     ,"5"      ,"02"    ,""         })
   o:DelTableData("SXB" ,{"EYY"     ,"5"      ,"03"    ,""         })
   o:DelTableData("SXB" ,{"EYY"     ,"5"      ,"04"    ,""         })
   //Implementa a nova consulta
   o:TableStruct("SXB",{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"    ,"XB_DESCSPA"    ,"XB_DESCENG" ,"XB_CONTEM"              ,"XB_WCONTEM"})
   o:TableData(  "SXB",{"EYY"     ,"1"      ,"01"    ,"RE"       ,"N.F.s de Entrada","Fact de entrada" ,"Inbound Invoices","SD1"            ,            })
   o:TableData(  "SXB",{"EYY"     ,"2"      ,"01"    ,"01"       ,""                ,""                ,""                ,"AE110SD1F3()"   ,            })
   o:TableData(  "SXB",{"EYY"     ,"5"      ,"01"    ,""         ,""                ,""                ,""                ,"SD1->D1_DOC"    ,            })
   o:TableData(  "SXB",{"EYY"     ,"5"      ,"02"    ,""         ,""                ,""                ,""                ,"SD1->D1_SERIE"  ,            })
   o:TableData(  "SXB",{"EYY"     ,"5"      ,"03"    ,""         ,""                ,""                ,""                ,"SD1->D1_FORNECE",            })
   o:TableData(  "SXB",{"EYY"     ,"5"      ,"04"    ,""         ,""                ,""                ,""                ,"SD1->D1_LOJA"   ,            })

   o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_USADO"    },2)
   o:TableData  ("SX3",{"EYY_SEQEMB" ,TODOS_MODULOS })
   o:TableData  ("SX3",{"EYY_D1ITEM" ,TODOS_MODULOS })
   o:TableData  ("SX3",{"EYY_D1PROD" ,TODOS_MODULOS })
   o:TableData  ("SX3",{"EYY_QUANT"  ,TODOS_MODULOS })
EndIf */

//WHRS-08/02/17 TE-4717 505045 / MTRADE-503 - Não está gravando os preços por container na tabela do armador.(Prometido 13/02)
o:TableStruct('SX3' ,{'X3_CAMPO'   ,'X3_GRPSXG'},2)
o:TableData  ('SX3' ,{'EWU_ARMADO' ,"001" })
o:TableData  ('SX3' ,{'EWV_ARMADO' ,"001" })

//MFR - 08/02/2017
o:TableStruct("SX3"  ,{"X3_CAMPO" ,"X3_USADO", "X3_RESERV"},2)
o:TableData  ("SX3"  ,{"EE8_TES"   ,TODOS_MODULOS, USO+OBRIGAT})
o:TableData  ("SX3"  ,{"EE8_CF"   , TODOS_MODULOS, USO+OBRIGAT})


o:TableStruct("SX6",{"X6_FIL"   ,"X6_VAR"     ,"X6_TIPO","X6_DESCRIC"                                     ,"X6_DSCSPA" ,"X6_DSCENG" ,"X6_DESC1"                                        ,"X6_DSCSPA1","X6_DSCENG1","X6_DESC2"                           ,"X6_DSCSPA2","X6_DSCENG2","X6_CONTEUD","X6_CONTSPA","X6_CONTENG","X6_PROPRI","X6_PYME","X6_VALID", "X6_INIT", "X6_DEFPOR", "X6_DEFSPA", "X6_DEFENG"},1)
o:TableData("SX6"  ,{"  "       ,"MV_EEC0052" ,"N"      ,"Configura como será calculado peso bruto da NFS",""          ,""          ,"sem considerar quebra por lote 1-Por Item da NF" ,            ,            ,"2-Por Nota Fiscal 3-Por Item pedido",""          ,""          ,"1"          ,            ,            ,"S"        ,"S"      ,""        , ""       , ""         , ""         , ""         })

n0052 := EasyGParam("MV_EEC0052",,1)
if empty(n0052) 
	SetMV("MV_EEC0052","1")
endif    

//WHRS - 31/03/2017 TE-4966 507485 / 506246 / MTRADE-607 - Cotação de moedas
o:TableStruct("SX6",{"X6_FIL"   ,"X6_VAR"     ,"X6_TIPO","X6_DESCRIC"                                      ,"X6_DSCSPA" ,"X6_DSCENG" ,"X6_DESC1"                      ,"X6_DSCSPA1","X6_DSCENG1","X6_DESC2","X6_DSCSPA2","X6_DSCENG2","X6_CONTEUD","X6_CONTSPA","X6_CONTENG","X6_PROPRI","X6_PYME","X6_VALID", "X6_INIT", "X6_DEFPOR", "X6_DEFSPA", "X6_DEFENG"},1)
o:TableData("SX6"  ,{"  "       ,"MV_EEC0055" ,"C"      ,"Sincronizar a cotação de moedas entre os módulos",""          ,""          ,"SIGAEEC e SIGAFIN. S=Sim N=Não",            ,            ,""        ,""          ,""          ,""          ,            ,            ,"S"        ,"S"      ,""        , ""       , ""         , ""         , ""         })

//THTS - 20/04/2017 - TE-5386 512356 / MTRADE-781 - Erro ao excluir cotacao de moedas
o:TableStruct("SX9",{"X9_DOM","X9_IDENT"  ,"X9_CDOM" ,"X9_EXPDOM"			,"X9_EXPCDOM"      		,"X9_PROPRI","X9_LIGDOM","X9_LIGCDOM","X9_CONDSQL","X9_USEFIL","X9_ENABLE"	,"X9_VINFIL"	,"X9_CHVFOR"},2)
o:TableData(  "SX9",{"SYE"   ,"004"       ,"SWB"     ,"YE_DATA+YE_MOEDA"	,"WB_DT_CONT+WB_MOEDA"	,"S"        ,"1"        ,"N"         ,""          ,""         ,"S"		  		,"2"		  	,"2"})

o:TableStruct("SX5",{"X5_FILIAL"   ,"X5_TABELA","X5_CHAVE","X5_DESCRI"})
o:TableData(  "SX5",{xFilial("SX5"),"ZY"       ,"EFF"     ,"FINANCING"})

//NCF - 19/06/2017 - TE-5909
o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_ORDEM"    },2)
o:TableData  ("SX3",{"EE7_CONSIG" ,"40"          })
o:TableData  ("SX3",{"EE7_COLOJA" ,"41"          })
o:TableData  ("SX3",{"EE7_CONSDE" ,"42"          })

//THTS - 27/06/2017 - TE6014
o:TableStruct("HELP" ,{"NOME"       ,"PROBLEMA"   ,"SOLUCAO"})
o:TableData  ("HELP" ,{"EECFATCP01" ,"Esta rotina só poderá ser utilizada com ambientes integrados ao faturamento do  Protheus (MV_EECFAT)."    ,"Para utilizar a rotina, habilite o parâmetro MV_EECFAT."  })

//Status da Due
AtuStatusDUE()
Return Nil


/*
Funcao                     : UPDEEC016
Parametros                 : Objeto de update PAI
Retorno                    : Nenhum
Objetivos                  : Atualização de dicionários e helps
Autor       			      : Wanderson Reliquias WHRS
Data/Hora   			      : 12/05/2017
Data/Hora Ultima alteração :
Revisao                    :
Obs.                       :
*/
Function UPDEEC016(o)
Local aOrd := {}

/*WHRS     TE-5406 508979 / MTRADE-674 /1000 - Ao selecionar o item da invoice, não apresenta o preço unitário e número do pedido*/

o:TableStruct( 'SX3',{'X3_CAMPO','X3_RELACAO'                                                                       },2)
//o:TableData('SX3',{cEXRCampo  ,'IF(TYPE("M->"+SX3->X3_CAMPO)<>"U",&("M->"+SX3->X3_CAMPO),SPACE(SX3->X3_TAMANHO))' })
o:TableData('SX3',{"EXR_PEDIDO" ,"IIF(IsMemVar('M->EXR_PEDIDO'),M->EXR_PEDIDO,'')" }) 
o:TableData('SX3',{"EXR_COD_I"  ,"IIF(IsMemVar('M->EXR_COD_I') ,M->EXR_COD_I ,'')" })
o:TableData('SX3',{"EXR_FORN "  ,"IIF(IsMemVar('M->EXR_FORN')  ,M->EXR_FORN  ,'')" })
o:TableData('SX3',{"EXR_FOLOJA" ,"IIF(IsMemVar('M->EXR_FOLOJA'),M->EXR_FOLOJA,'')" })
o:TableData('SX3',{"EXR_FABR"   ,"IIF(IsMemVar('M->EXR_FABR')  ,M->EXR_FABR  ,'')" })
o:TableData('SX3',{"EXR_FALOJA" ,"IIF(IsMemVar('M->EXR_FALOJA'),M->EXR_FALOJA,'')" })
o:TableData('SX3',{"EXR_PRECO"  ,"IIF(IsMemVar('M->EXR_PRECO') ,M->EXR_PRECO ,'')" })
o:TableData('SX3',{"EXR_PSLQUN" ,"IIF(IsMemVar('M->EXR_PSLQUN'),M->EXR_PSLQUN,'')" })
o:TableData('SX3',{"EXR_PSBRUN" ,"IIF(IsMemVar('M->EXR_PSBRUN'),M->EXR_PSBRUN,'')" })
o:TableData('SX3',{"EXR_LC_NUM" ,"IIF(IsMemVar('M->EXR_LC_NUM'),M->EXR_LC_NUM,'')" })

//LRS - 19/05/2017
 o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_USADO"    },2)
 o:TableData  ("SX3",{"EEQ_IMLOJA" ,TODOS_MODULOS })

//Status da Due
AtuStatusDUE()

//LRS - 09/08/2017
o:TableStruct("SX7",{'X7_CAMPO' ,'X7_SEQUENC','X7_REGRA'                                                ,'X7_CDOMIN','X7_CONDIC'          })
o:TableData  ('SX7',{'EEQ_TX'   ,'001'       ,"M->EEQ_TX*IF(Type('nTotFFC')='N',nTotFFC,M->EEQ_VLFCAM)" ,'EEQ_EQVL' ,'TYPE("LISEMB")<>"L" .OR. LISEMB' })
o:DelTableData  ('SX7',{'EEQ_TX'   ,'002'       ,"M->EEQ_TX*M->EEQ_VLFCAM"                                 ,'EEQ_EQVL' ,'' })

// EJA - 09/08/2017
o:TableStruct("SX3",{"X3_CAMPO" ,"X3_PICTURE" },2)
o:TableData("SX3"  ,{"EXL_DPFR" ,"@E 999"     })
o:TableData("SX3"  ,{"EXL_DPSE" ,"@E 999"     })
o:TableData("SX3"  ,{"EXL_DPFA" ,"@E 999"     })
o:TableData("SX3"  ,{"EXL_DPDI" ,"@E 999"     })

o:TableData("SX3"  ,{"EXL_EMFR" ,"@!"         })
o:TableData("SX3"  ,{"EXL_EMSE" ,"@!"         })
o:TableData("SX3"  ,{"EXL_EMFA" ,"@!"         })
o:TableData("SX3"  ,{"EXL_EMDI" ,"@!"         })

Return nil


/*
Funcao                     : UPDEEC017
Parametros                 : Objeto de update PAI
Retorno                    : Nenhum
Objetivos                  : Atualização de dicionários e helps
Autor       			   : Lucas Raminelli
Data/Hora   			   : 28/07/2017
Data/Hora Ultima alteração :
Revisao                    :
Obs.                       :
*/
Function UPDEEC017(o)

/* THTS 0- 16/10/2017 - NOPADO - TE-7258 - Conforme orientacao da Engenharia Totvs, pois nao pode criar novos grupos SXG via RUP, 
   pois implica em mudanca no modelo de dados, resultando erro na migração de release.

o:TableStruct("SXG",{"XG_GRUPO", "XG_DESCRI"            , "XG_DESSPA", "XG_DESENG", "XG_SIZEMAX", "XG_SIZEMIN", "XG_SIZE", "XG_PICTURE"})
o:TableData  ("SXG",{"128"     , "Parcelas de câmbio"   ,            ,            , "7"         , "1"         , "2"      , "@!"        })
*/

Local aDados := {}

//LRS - 28/07/2017 - Parametros DU-E
o:TableStruct("SX6",{"X6_FIL"   ,"X6_VAR"     ,"X6_TIPO","X6_DESCRIC"                                        ,"X6_DSCSPA" ,"X6_DSCENG" ,"X6_DESC1"                                           ,"X6_DSCSPA1","X6_DSCENG1","X6_DESC2","X6_DSCSPA2","X6_DSCENG2","X6_CONTEUD","X6_CONTSPA","X6_CONTENG","X6_PROPRI","X6_PYME","X6_VALID", "X6_INIT", "X6_DEFPOR", "X6_DEFSPA", "X6_DEFENG"})
o:TableData("SX6"  ,{""         ,"MV_EEC0053" ,"L"      ,"Define se utiliza a Declaracao Unica de Exportacao",""          ,""          ,""                                                   ,            ,            ,""        ,""          ,""          ,".T."       ,            ,            ,"S"        ,"S"      ,""        , ""       , ""         , ""         , ""         })
o:TableData("SX6"  ,{""         ,"MV_EEC0054" ,"N"      ,"Integrador deve efetuar integracao com a          ",""          ,""          ,"base de Testes (1) ou com a base de Producao (2)  " ,            ,            ,""        ,""          ,""          ,"1"         ,            ,            ,"S"        ,"S"      ,""        , ""       , ""         , ""         , ""         })

//LRS - 14/09/2017
o:TableStruct('SX2',{'X2_CHAVE','X2_UNICO'                                                                     })
o:TableData  ('SX2',{"EEJ"     ,'EEJ_FILIAL+EEJ_PEDIDO+EEJ_OCORRE+EEJ_TIPOBC+EEJ_CODIGO+EEJ_AGENCI+EEJ_NUMCON' }) //LRS - 14/09/2017

o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_ORDEM" },2) 
o:TableData  ("SX3",{"EE7_BENEF"  ,"43"       })
o:TableData  ("SX3",{"EE7_BELOJA" ,"44"       })

o:TableStruct("SX7",{'X7_CAMPO'   ,'X7_SEQUENC','X7_REGRA'      },1)
o:TableData  ('SX7',{'EE7_BELOJA' ,'002'       ,'IF(!EMPTY(M->EE7_BENEF),EECMEND("SA2",1,M->EE7_BENEF+M->EE7_BELOJA,.T.,AvSx3("EE7_ENDBEN",3),1),"")' })

// MPG - MTRADE-1519-13/12/2017
o:TableStruct("SX7",{'X7_CAMPO'   ,'X7_SEQUENC'  , 'X7_REGRA'              ,'X7_CDOMIN'  ,'X7_TIPO' ,'X7_SEEK'  ,'X7_ALIAS' , 'X7_ORDEM' , 'X7_CHAVE' , 'X7_CONDIC'        ,'X7_PROPRI'},1)
o:TableData  ("SX7",{"EEQ_DESCON" ,"003"         ,"M->EEQ_VL-M->EEQ_DESCON",'EEQ_VLFCAM' ,'P'       ,'N'        ,           ,            ,            ,'!lFinanciamento'   ,"S"        }  )

o:TableStruct("SX3",{"X3_ARQUIVO","X3_CAMPO"  ,"X3_TAMANHO"})
o:TableData(  "SX3",{"EEX"       ,"EEX_TIPOPX","2"         })
o:TableData(  "SX3",{"EEX"       ,"EEX_DETOPX","2"         })
o:TableData(  "SX3",{"EEX"       ,"EEX_SDETOP","2"         })

// EJA - 21/09/2017
o:TableStruct("SX3", {"X3_CAMPO",   "X3_USADO"}, 2)
o:TableData(  "SX3" ,{"EEQ_NRINVO", TODOS_MODULOS})
o:TableData(  "SX3" ,{"EE3_SEQ"   , TODOS_AVG})
o:TableData(  "SX3" ,{"A1_NATUREZ", TODOS_MODULOS})
o:TableData(  "SX3" ,{"A2_NATUREZ", TODOS_MODULOS})

//LRS - 06/03/2018
o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_ORDEM" },2) 
o:TableData  ("SX3",{"EE7_FORN"   ,"33"       })
o:TableData  ("SX3",{"EE7_FOLOJA" ,"34"       })

//LRS - 20/10/2017 - Carga Pagrão EYG Retirado do EECAE100
If ChkFile("EYG") .And. !EYG->(DBSeek(xFilial() + "22B0"))
    o:TableStruct('EYG',{'EYG_CODCON','EYG_DESCON','EYG_COMCON','EYG_ALTCON'},1)
    o:TableData('EYG',{'22B0','20 Bulk                                                     ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22P3','20 Collapsible Flat Rack                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22P1','20 Flat Rack                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2510','20 HIGH CUBE                                                ',              20,              9.5},,.F.)
    o:TableData('EYG',{'22UP','20 Hard Top                                                 ',              20,              8.5},,.F.)
    o:TableData('EYG',{'25GP','20 High Cube                                                ',              20,              9.6},,.F.)
    o:TableData('EYG',{'22H0','20 Insulated (Conair)                                       ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2551','20 OPEN TOP HIGHCUBE                                        ',              20,              9.5},,.F.)
    o:TableData('EYG',{'22U1','20 Open Top                                                 ',              20,              8.5},,.F.)
    o:TableData('EYG',{'29P0','20 Platform                                                 ',              20,              1},,.F.)
    o:TableData('EYG',{'22R1','20 Reefer                                                   ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22G0','20 Standard Dry                                             ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22T0','20 Tank                                                     ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22VH','20 Ventilated                                               ',              20,              8.5},,.F.)
    o:TableData('EYG',{'42P3','40 Collapsible Flat Rack                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42P1','40 Flat Rack                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4563','40 Flat Rack                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4205','40 General Purpose (Hanging Garments)                       ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4534','40 HIGHCUBE INTEGRATED REEFER                               ',              40,              9.5},,.F.)
    o:TableData('EYG',{'45G0','40 High Cube                                                ',              40,              9.5},,.F.)
    o:TableData('EYG',{'45GP','40 High Cube                                                ',              40,              9.5},,.F.)
    o:TableData('EYG',{'45U6','40 High Cube Hard Top                                       ',              40,              9.5},,.F.)
    o:TableData('EYG',{'45UP','40 High Cube Hard Top                                       ',              40,              9.5},,.F.)
    o:TableData('EYG',{'42H0','40 Insulated (Conair)                                       ',              40,              8.5},,.F.)
    o:TableData('EYG',{'45U0','40 OPENTOP HIGH CUBE                                        ',              40,              9.6},,.F.)
    o:TableData('EYG',{'49P0','40 Platform                                                 ',              40,              4},,.F.)
    o:TableData('EYG',{'42R1','40 Reefer                                                   ',              40,              8.5},,.F.)
    o:TableData('EYG',{'45R1','40 Reefer High Cube                                         ',              40,              9.5},,.F.)
    o:TableData('EYG',{'42G0','40 Standard Dry                                             ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42VH','40 Ventilated                                               ',              40,              8.5},,.F.)
    o:TableData('EYG',{'L5G1','45 High Cube                                                ',              45,              9},,.F.)
    o:TableData('EYG',{'L5R1','45 Reefer High Cube                                         ',              45,              9.5},,.F.)
    o:TableData('EYG',{'2994','Air/Surface                                                 ',              20,              4},,.F.)
    o:TableData('EYG',{'4599','Air/Surface                                                 ',              40,              9},,.F.)
    o:TableData('EYG',{'4595','Air/Surface                                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4699','Air/Surface                                                 ',              40,              4.25},,.F.)
    o:TableData('EYG',{'8599','Air/Surface                                                 ',              35,              8.5},,.F.)
    o:TableData('EYG',{'9998','Air/Surface                                                 ',              40,              4},,.F.)
    o:TableData('EYG',{'4096','Air/Surface                                                 ',              40,              8},,.F.)
    o:TableData('EYG',{'2299','Air/Surface                                                 ',              20,              8.5},,.F.)
    o:TableData('EYG',{'9999','Air/Surface                                                 ',              40,              4},,.F.)
    o:TableData('EYG',{'9995','Air/Surface                                                 ',              40,              4},,.F.)
    o:TableData('EYG',{'4994','Air/Surface                                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4326','Automobile Carrier                                          ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4426','Automobile Carrier                                          ',              40,              9},,.F.)
    o:TableData('EYG',{'4226','Automobile Carrier                                          ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4026','Automobile Carrier                                          ',              40,              8},,.F.)
    o:TableData('EYG',{'4126','Automobile Carrier                                          ',              40,              8},,.F.)
    o:TableData('EYG',{'28U1','BIN HALF HEIGHT (OPEN TOP)                                  ',              20,              4.25},,.F.)
    o:TableData('EYG',{'22V0','Closed Vented                                               ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22V2','Closed Vented                                               ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22V4','Closed Vented                                               ',              20,              8.5},,.F.)
    o:TableData('EYG',{'20VH','Closed Vented                                               ',              20,              8},,.F.)
    o:TableData('EYG',{'20V4','Closed Vented                                               ',              20,              8},,.F.)
    o:TableData('EYG',{'20V2','Closed Vented                                               ',              20,              8},,.F.)
    o:TableData('EYG',{'20V0','Closed Vented                                               ',              20,              8},,.F.)
    o:TableData('EYG',{'2011','Closed Vented                                               ',              20,              8},,.F.)
    o:TableData('EYG',{'2010','Closed Vented                                               ',              20,              8},,.F.)
    o:TableData('EYG',{'4311','Closed Vented                                               ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42V4','Closed Vented                                               ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4211','Closed Vented                                               ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4210','Closed Vented                                               ',              40,              8.5},,.F.)
    o:TableData('EYG',{'40VH','Closed Vented                                               ',              40,              8},,.F.)
    o:TableData('EYG',{'40V4','Closed Vented                                               ',              40,              8},,.F.)
    o:TableData('EYG',{'40V2','Closed Vented                                               ',              40,              8},,.F.)
    o:TableData('EYG',{'40V0','Closed Vented                                               ',              40,              8},,.F.)
    o:TableData('EYG',{'4011','Closed Vented                                               ',              40,              8},,.F.)
    o:TableData('EYG',{'4010','Closed Vented                                               ',              40,              8},,.F.)
    o:TableData('EYG',{'2211','Closed Vented                                               ',              20,              8.5},,.F.)
    o:TableData('EYG',{'42V2','Closed Vented                                               ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42V0','Closed Vented                                               ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4315','Closed Ventilated                                           ',              40,              8.5},,.F.)
    o:TableData('EYG',{'2013','Closed Ventilated                                           ',              20,              8},,.F.)
    o:TableData('EYG',{'2215','Closed Ventilated                                           ',              20,              8.5},,.F.)
    o:TableData('EYG',{'4215','Closed Ventilated                                           ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4015','Closed Ventilated                                           ',              40,              8},,.F.)
    o:TableData('EYG',{'2217','Closed Ventilated                                           ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2216','Closed Ventilated                                           ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2117','Closed Ventilated                                           ',              20,              8},,.F.)
    o:TableData('EYG',{'2113','Closed Ventilated                                           ',              20,              8},,.F.)
    o:TableData('EYG',{'2017','Closed Ventilated                                           ',              20,              8},,.F.)
    o:TableData('EYG',{'2015','Closed Ventilated                                           ',              20,              8},,.F.)
    o:TableData('EYG',{'30G0','DRY CARGO/GENERAL PURPOSE                                   ',              30,              8},,.F.)
    o:TableData('EYG',{'10G0','DRY CARGO/GENERAL PURPOSE                                   ',              10,              8},,.F.)
    o:TableData('EYG',{'12G0','DRY CARGO/GENERAL PURPOSE                                   ',              10,              8.5},,.F.)
    o:TableData('EYG',{'32G0','DRY CARGO/GENERAL PURPOSE                                   ',              30,              8.5},,.F.)
    o:TableData('EYG',{'4319','DV Closed containers Ventilated, Spare                      ',              40,              8.5},,.F.)
    o:TableData('EYG',{'2219','DV Closed containers Ventilated, Spare                      ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22B1','Dry Bulk                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22B3','Dry Bulk                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22B4','Dry Bulk                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22B5','Dry Bulk                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22B6','Dry Bulk                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22BK','Dry Bulk                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'40B3','Dry Bulk                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40B1','Dry Bulk                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40B0','Dry Bulk                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4080','Dry Bulk                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'2281','Dry Bulk                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2280','Dry Bulk                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'20BU','Dry Bulk                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20BK','Dry Bulk                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20B6','Dry Bulk                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'42BU','Dry Bulk                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42BK','Dry Bulk                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42B6','Dry Bulk                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42B5','Dry Bulk                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42B4','Dry Bulk                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42B3','Dry Bulk                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42B1','Dry Bulk                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42B0','Dry Bulk                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4280','Dry Bulk                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'40BU','Dry Bulk                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40BK','Dry Bulk                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40B6','Dry Bulk                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40B5','Dry Bulk                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40B4','Dry Bulk                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'22BU','Dry Bulk                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'20B5','Dry Bulk                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20B4','Dry Bulk                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20B3','Dry Bulk                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20B1','Dry Bulk                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20B0','Dry Bulk                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'2080','Dry Bulk                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'4886','Dry Bulk                                                    ',              40,              4.25},,.F.)
    o:TableData('EYG',{'4380','Dry Bulk                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'45P3','FOLDING COMPLETE END STRUCTURE (PLATFORM)                   ',              40,              9.5},,.F.)
    o:TableData('EYG',{'45PC','FOLDING COMPLETE END STRUCTURE (PLATFORM)                   ',              40,              9.5},,.F.)
    o:TableData('EYG',{'4361','Flat                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4363','Flat                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'2160','Flat                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2063','Flat                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2260','Flat                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2263','Flat                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'4260','Flat                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4360','Flat                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4263','Flat                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4060','Flat                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'2261','Flat                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'4999','GOOSENECK CHASSIS                                           ',              40,             0},,.F.)
    o:TableData('EYG',{'42G4','General Purose (Hanging Garments)                           ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4312','General Purpose (Hanging Garments)                          ',              40,              8.5},,.F.)
    o:TableData('EYG',{'2212','General Purpose (Hanging Garments)                          ',              20,              8.5},,.F.)
    o:TableData('EYG',{'48UI','HALF HEIGHT (OPEN TOP)                                      ',              40,              4.25},,.F.)
    o:TableData('EYG',{'2870','HALF HEIGHT THERMAL TANK                                    ',              20,             0},,.F.)
    o:TableData('EYG',{'4651','HALF HIGH                                                   ',              40,             0},,.F.)
    o:TableData('EYG',{'2851','HALF OPEN TOP                                               ',              20,             0},,.F.)
    o:TableData('EYG',{'2410','HIGH CUBE                                                   ',              20,              9.5},,.F.)
    o:TableData('EYG',{'4410','HIGH CUBE                                                   ',              40,              9.5},,.F.)
    o:TableData('EYG',{'4514','HIGH CUBE                                                   ',              40,              9.5},,.F.)
    o:TableData('EYG',{'L0GP','HL: OPENING(S) AT ONE END OR BOTH ENDS                      ',              45,              8},,.F.)
    o:TableData('EYG',{'2224','Insulated                                                   ',              20,              8.5},,.F.)
    o:TableData('EYG',{'4224','Insulated                                                   ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4325','Livestock Carrier                                           ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4225','Livestock Carrier                                           ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4025','Livestock Carrier                                           ',              40,              8},,.F.)
    o:TableData('EYG',{'2125','Livestock Carrier                                           ',              20,              8},,.F.)
    o:TableData('EYG',{'2225','Livestock Carrier                                           ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2025','Livestock Carrier                                           ',              20,              8},,.F.)
    o:TableData('EYG',{'4551','OPEN TOP HIGHCUBE                                           ',              40,              9.5},,.F.)
    o:TableData('EYG',{'M2G0','OPENING(S) AT ONE END OR BOTH ENDS                          ',              48,              8.5},,.F.)
    o:TableData('EYG',{'4CG0','OPENING(S) AT ONE OR BOTH ENDS                              ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4CGP','OPENING(S) AT ONE OR BOTH ENDS                              ',              40,              8.5},,.F.)
    o:TableData('EYG',{'28U2','OPENING(S) AT ONE OR BOTH ENDS, PLUS REMV TOP MEMB          ',              20,              8.5},,.F.)
    o:TableData('EYG',{'28UT','OPENING(S) AT ONE OR BOTH ENDS, PLUS REMV TOP MEMB          ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22U2','Open Top                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22U3','Open Top                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22U4','Open Top                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2053','Open Top                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'2052','Open Top                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'2051','Open Top                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'2050','Open Top                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'4750','Open Top                                                    ',              40,              4.25},,.F.)
    o:TableData('EYG',{'4650','Open Top                                                    ',              40,              4.25},,.F.)
    o:TableData('EYG',{'4351','Open Top                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4350','Open Top                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42U5','Open Top                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42U4','Open Top                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42U3','Open Top                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42U2','Open Top                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'2650','Open Top                                                    ',             0,              4.25},,.F.)
    o:TableData('EYG',{'2253','Open Top                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2252','Open Top                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2251','Open Top                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2250','Open Top                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2150','Open Top                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20UT','Open Top                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20U5','Open Top                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20U4','Open Top                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20U3','Open Top                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'40U2','Open Top                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40U1','Open Top                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40U0','Open Top                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4053','Open Top                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4052','Open Top                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4051','Open Top                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4050','Open Top                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'22U0','Open Top                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2259','Open Top                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22UT','Open Top                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'42UT','Open Top                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42U0','Open Top                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42P6','Open Top                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4253','Open Top                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4252','Open Top                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4251','Open Top                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4250','Open Top                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'40UT','Open Top                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40U5','Open Top                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40U4','Open Top                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40U3','Open Top                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'20U2','Open Top                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20U1','Open Top                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20U0','Open Top                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'4751','Open Top                                                    ',              40,              4.25},,.F.)
    o:TableData('EYG',{'2750','Open Top                                                    ',              20,              4.25},,.F.)
    o:TableData('EYG',{'2651','Open Top                                                    ',              20,              4.25},,.F.)
    o:TableData('EYG',{'22U5','Open Top                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'48U0','Open top                                                    ',              40,              4.25},,.F.)
    o:TableData('EYG',{'8550','Open top                                                    ',              35,              8.5},,.F.)
    o:TableData('EYG',{'48UT','Open top                                                    ',              40,              4.25},,.F.)
    o:TableData('EYG',{'B2G1','PASSIVE VENTS AT UPPER PART OF CARGO SPACE                  ',              24,              8.5},,.F.)
    o:TableData('EYG',{'4CG1','PASSIVE VENTS AT UPPER PART OF CARGO SPACE                  ',              40,              8.5},,.F.)
    o:TableData('EYG',{'29P1','PLATFORM (CONTAINER)                                        ',              20,              4},,.F.)
    o:TableData('EYG',{'29PL','PLATFORM (CONTAINER)                                        ',              20,              1},,.F.)
    o:TableData('EYG',{'22P7','PLATFORM FIXED                                              ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22P2','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2361','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2363','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'4561','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4560','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4367','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42P4','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42P2','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'2761','Platform                                                    ',              20,              4.25},,.F.)
    o:TableData('EYG',{'2661','Platform                                                    ',              20,              4.25},,.F.)
    o:TableData('EYG',{'2367','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2366','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2365','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2364','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2362','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'40P0','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4067','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4066','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4065','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4064','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4063','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4062','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4061','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'2969','Platform                                                    ',              20,              4},,.F.)
    o:TableData('EYG',{'42PF','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'49PL','Platform                                                    ',              40,              4},,.F.)
    o:TableData('EYG',{'22PC','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'42PC','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'22PF','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'4960','Platform                                                    ',              40,              4},,.F.)
    o:TableData('EYG',{'48P0','Platform                                                    ',              40,              4.25},,.F.)
    o:TableData('EYG',{'45P8','Platform                                                    ',              40,              9.5},,.F.)
    o:TableData('EYG',{'42P0','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4267','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4266','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4265','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4264','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4262','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4261','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4167','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4166','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4165','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4164','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4163','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4162','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4161','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40PS','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40PL','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40PF','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40PC','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40P5','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40P4','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40P3','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40P2','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40P1','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'2960','Platform                                                    ',              20,              4},,.F.)
    o:TableData('EYG',{'2760','Platform                                                    ',              20,              4.25},,.F.)
    o:TableData('EYG',{'22P0','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2267','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2266','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2265','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2264','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2262','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2167','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'2166','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'2165','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'2164','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'2163','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'2162','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'2161','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20P2','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20P1','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20P0','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'49PF','Platform                                                    ',              40,              4},,.F.)
    o:TableData('EYG',{'49PC','Platform                                                    ',              40,              4},,.F.)
    o:TableData('EYG',{'49P5','Platform                                                    ',              40,              4},,.F.)
    o:TableData('EYG',{'49P3','Platform                                                    ',              40,              4},,.F.)
    o:TableData('EYG',{'49P1','Platform                                                    ',              40,              4},,.F.)
    o:TableData('EYG',{'4366','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'20PS','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20PL','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20PF','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20PC','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20P5','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20P4','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20P3','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'4365','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4364','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4362','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42PS','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42PL','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42P9','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42P8','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42P5','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'2067','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'2066','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'2065','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'2064','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'2062','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'2061','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'2060','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'48PL','Platform                                                    ',              40,              4.25},,.F.)
    o:TableData('EYG',{'48PF','Platform                                                    ',              40,              4.25},,.F.)
    o:TableData('EYG',{'48PC','Platform                                                    ',              40,              4.25},,.F.)
    o:TableData('EYG',{'48P5','Platform                                                    ',              40,              4.25},,.F.)
    o:TableData('EYG',{'48P3','Platform                                                    ',              40,              4.25},,.F.)
    o:TableData('EYG',{'48P1','Platform                                                    ',              40,              4.25},,.F.)
    o:TableData('EYG',{'4761','Platform                                                    ',              40,              4.25},,.F.)
    o:TableData('EYG',{'4661','Platform                                                    ',              40,              4.25},,.F.)
    o:TableData('EYG',{'22P4','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22PL','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22PS','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22P9','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22P8','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22P5','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2999','SLIDER CHASSIS                                              ',              20,             0},,.F.)
    o:TableData('EYG',{'7999','SLIDER CHASSIS                                              ',              20,             0},,.F.)
    o:TableData('EYG',{'22G1','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'24GP','Standard Dry                                                ',              20,              9},,.F.)
    o:TableData('EYG',{'24G3','Standard Dry                                                ',              20,              9},,.F.)
    o:TableData('EYG',{'24G2','Standard Dry                                                ',              20,              9},,.F.)
    o:TableData('EYG',{'24G1','Standard Dry                                                ',              20,              9},,.F.)
    o:TableData('EYG',{'24G0','Standard Dry                                                ',              20,              9},,.F.)
    o:TableData('EYG',{'2304','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2303','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2302','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2301','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2300','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22V3','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22U6','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'L2GP','Standard Dry                                                ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L2G9','Standard Dry                                                ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L2G3','Standard Dry                                                ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L2G2','Standard Dry                                                ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L2G1','Standard Dry                                                ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L2G0','Standard Dry                                                ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L0G9','Standard Dry                                                ',              45,              8},,.F.)
    o:TableData('EYG',{'4511','Standard Dry                                                ',              40,              9.5},,.F.)
    o:TableData('EYG',{'4510','Standard Dry                                                ',              40,              9.5},,.F.)
    o:TableData('EYG',{'4505','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4500','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4400','Standard Dry                                                ',              40,              9},,.F.)
    o:TableData('EYG',{'4204','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4203','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4202','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4201','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4200','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4104','Standard Dry                                                ',              40,              8},,.F.)
    o:TableData('EYG',{'4103','Standard Dry                                                ',              40,              8},,.F.)
    o:TableData('EYG',{'4102','Standard Dry                                                ',              40,              8},,.F.)
    o:TableData('EYG',{'4101','Standard Dry                                                ',              40,              8},,.F.)
    o:TableData('EYG',{'40GP','Standard Dry                                                ',              40,              8},,.F.)
    o:TableData('EYG',{'40G3','Standard Dry                                                ',              40,              8},,.F.)
    o:TableData('EYG',{'40G2','Standard Dry                                                ',              40,              8},,.F.)
    o:TableData('EYG',{'40G1','Standard Dry                                                ',              40,              8},,.F.)
    o:TableData('EYG',{'40G0','Standard Dry                                                ',              40,              8},,.F.)
    o:TableData('EYG',{'4004','Standard Dry                                                ',              40,              8},,.F.)
    o:TableData('EYG',{'4003','Standard Dry                                                ',              40,              8},,.F.)
    o:TableData('EYG',{'4002','Standard Dry                                                ',              40,              8},,.F.)
    o:TableData('EYG',{'4001','Standard Dry                                                ',              40,              8},,.F.)
    o:TableData('EYG',{'4000','Standard Dry                                                ',              40,              8},,.F.)
    o:TableData('EYG',{'2213','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2210','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2205','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2204','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2203','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2202','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2201','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2200','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2104','Standard Dry                                                ',              20,              8},,.F.)
    o:TableData('EYG',{'2103','Standard Dry                                                ',              20,              8},,.F.)
    o:TableData('EYG',{'2102','Standard Dry                                                ',              20,              8},,.F.)
    o:TableData('EYG',{'2101','Standard Dry                                                ',              20,              8},,.F.)
    o:TableData('EYG',{'20GP','Standard Dry                                                ',              20,              8},,.F.)
    o:TableData('EYG',{'20G3','Standard Dry                                                ',              20,              8},,.F.)
    o:TableData('EYG',{'20G2','Standard Dry                                                ',              20,              8},,.F.)
    o:TableData('EYG',{'20G1','Standard Dry                                                ',              20,              8},,.F.)
    o:TableData('EYG',{'20G0','Standard Dry                                                ',              20,              8},,.F.)
    o:TableData('EYG',{'2004','Standard Dry                                                ',              20,              8},,.F.)
    o:TableData('EYG',{'2003','Standard Dry                                                ',              20,              8},,.F.)
    o:TableData('EYG',{'2002','Standard Dry                                                ',              20,              8},,.F.)
    o:TableData('EYG',{'2001','Standard Dry                                                ',              20,              8},,.F.)
    o:TableData('EYG',{'2000','Standard Dry                                                ',              20,              8},,.F.)
    o:TableData('EYG',{'1200','Standard Dry                                                ',              10,              8.5},,.F.)
    o:TableData('EYG',{'1000','Standard Dry                                                ',              10,              8},,.F.)
    o:TableData('EYG',{'L5G9','Standard Dry                                                ',              45,              9.5},,.F.)
    o:TableData('EYG',{'L5G3','Standard Dry                                                ',              45,              9.5},,.F.)
    o:TableData('EYG',{'L5G2','Standard Dry                                                ',              45,              9.5},,.F.)
    o:TableData('EYG',{'9510','Standard Dry                                                ',              45,              9.5},,.F.)
    o:TableData('EYG',{'9500','Standard Dry                                                ',              45,              9.5},,.F.)
    o:TableData('EYG',{'9400','Standard Dry                                                ',              45,              9.5},,.F.)
    o:TableData('EYG',{'9200','Standard Dry                                                ',              45,              8.5},,.F.)
    o:TableData('EYG',{'8500','Standard Dry                                                ',              35,              8.5},,.F.)
    o:TableData('EYG',{'45G3','Standard Dry                                                ',              40,              9.5},,.F.)
    o:TableData('EYG',{'45G2','Standard Dry                                                ',              40,              9.5},,.F.)
    o:TableData('EYG',{'45G1','Standard Dry                                                ',              40,              9.5},,.F.)
    o:TableData('EYG',{'44GP','Standard Dry                                                ',              40,              9},,.F.)
    o:TableData('EYG',{'44G3','Standard Dry                                                ',              40,              9},,.F.)
    o:TableData('EYG',{'44G2','Standard Dry                                                ',              40,              9},,.F.)
    o:TableData('EYG',{'44G1','Standard Dry                                                ',              40,              9},,.F.)
    o:TableData('EYG',{'44G0','Standard Dry                                                ',              40,              9},,.F.)
    o:TableData('EYG',{'4310','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4305','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4304','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4303','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4302','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4301','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4300','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42U6','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42G3','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42G2','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42G1','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'3200','Standard Dry                                                ',              30,              8.5},,.F.)
    o:TableData('EYG',{'3000','Standard Dry                                                ',              30,              8},,.F.)
    o:TableData('EYG',{'28G0','Standard Dry                                                ',              20,              4.25},,.F.)
    o:TableData('EYG',{'26GP','Standard Dry                                                ',              20,              9.5},,.F.)
    o:TableData('EYG',{'26G3','Standard Dry                                                ',              20,              9.5},,.F.)
    o:TableData('EYG',{'26G2','Standard Dry                                                ',              20,              9.5},,.F.)
    o:TableData('EYG',{'26G1','Standard Dry                                                ',              20,              9.5},,.F.)
    o:TableData('EYG',{'26G0','Standard Dry                                                ',              20,              9.5},,.F.)
    o:TableData('EYG',{'2600','Standard Dry                                                ',              20,              4.25},,.F.)
    o:TableData('EYG',{'2500','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22G2','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'L5GP','Standard Dry                                                ',              45,              9.5},,.F.)
    o:TableData('EYG',{'42GP','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'22GP','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'L5G0','Standard Dry                                                ',              45,              9},,.F.)
    o:TableData('EYG',{'28GP','Standard Dry                                                ',              20,              4.25},,.F.)
    o:TableData('EYG',{'22G3','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'25G0','Standard Dry High Cube                                      ',              20,              9},,.F.)
    o:TableData('EYG',{'2530','THERMAL CNTR,REFRIGERATED,EXPENDABLE REFRIGANT              ',              20,              8.5},,.F.)
    o:TableData('EYG',{'3399','TRIAXLE CHASSIS                                             ',              23,             0},,.F.)
    o:TableData('EYG',{'22T1','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22T2','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22T4','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22T6','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22T8','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22TD','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2072','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2071','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2070','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'8770','Tank                                                        ',              35,              4.25},,.F.)
    o:TableData('EYG',{'42TG','Tank                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42TD','Tank                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42T9','Tank                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42T8','Tank                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42T7','Tank                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'20T1','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'20T0','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2079','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2078','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2077','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2076','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2075','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2074','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2073','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2275','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2274','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2273','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2272','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2271','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2270','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'20TN','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'20TG','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'20TD','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'40TD','Tank                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'40T9','Tank                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'40T8','Tank                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'40T7','Tank                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'40T6','Tank                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'40T5','Tank                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'40T4','Tank                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'40T3','Tank                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'40T2','Tank                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'42TN','Tank                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'22TN','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'4271','Tank                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4270','Tank                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4170','Tank                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'40TN','Tank                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'40TG','Tank                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'40T1','Tank                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'40T0','Tank                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'4071','Tank                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'4070','Tank                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'2279','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2278','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2277','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2276','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'20T9','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'20T8','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'20T7','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'20T6','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'20T5','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'20T4','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'20T3','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'20T2','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'42T6','Tank                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42T5','Tank                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42T4','Tank                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42T3','Tank                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42T2','Tank                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42T1','Tank                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'2771','Tank                                                        ',              20,              4.25},,.F.)
    o:TableData('EYG',{'2770','Tank                                                        ',              20,              4.25},,.F.)
    o:TableData('EYG',{'4370','Tank                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'2671','Tank                                                        ',              20,              4.25},,.F.)
    o:TableData('EYG',{'2670','Tank                                                        ',              20,              4.25},,.F.)
    o:TableData('EYG',{'22TG','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22T9','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22T7','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22T5','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22T3','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22H5','Thermal Insulated                                           ',              20,              8.5},,.F.)
    o:TableData('EYG',{'4420','Thermal Insulated                                           ',              40,              9},,.F.)
    o:TableData('EYG',{'40H6','Thermal Insulated                                           ',              40,              8},,.F.)
    o:TableData('EYG',{'40H5','Thermal Insulated                                           ',              40,              8},,.F.)
    o:TableData('EYG',{'4020','Thermal Insulated                                           ',              40,              8},,.F.)
    o:TableData('EYG',{'2220','Thermal Insulated                                           ',              20,              8.5},,.F.)
    o:TableData('EYG',{'20H6','Thermal Insulated                                           ',              20,              8},,.F.)
    o:TableData('EYG',{'20H5','Thermal Insulated                                           ',              20,              8},,.F.)
    o:TableData('EYG',{'2020','Thermal Insulated                                           ',              20,              8},,.F.)
    o:TableData('EYG',{'L5H6','Thermal Insulated                                           ',              45,              9.5},,.F.)
    o:TableData('EYG',{'L5H5','Thermal Insulated                                           ',              45,              9.5},,.F.)
    o:TableData('EYG',{'L2H6','Thermal Insulated                                           ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L2H5','Thermal Insulated                                           ',              45,              8.5},,.F.)
    o:TableData('EYG',{'44H6','Thermal Insulated                                           ',              40,              9},,.F.)
    o:TableData('EYG',{'44H5','Thermal Insulated                                           ',              40,              9},,.F.)
    o:TableData('EYG',{'4320','Thermal Insulated                                           ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42H6','Thermal Insulated                                           ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42H5','Thermal Insulated                                           ',              40,              8.5},,.F.)
    o:TableData('EYG',{'24H6','Thermal Insulated                                           ',              20,              9},,.F.)
    o:TableData('EYG',{'22H6','Thermal Insulated                                           ',              20,              8.5},,.F.)
    o:TableData('EYG',{'24H5','Thermal Insulated                                           ',              20,              9},,.F.)
    o:TableData('EYG',{'8520','Thermal Insulated                                           ',              35,              8.5},,.F.)
    o:TableData('EYG',{'45H6','Thermal Insulated                                           ',              45,              9.5},,.F.)
    o:TableData('EYG',{'45H5','Thermal Insulated                                           ',              45,              9.5},,.F.)
    o:TableData('EYG',{'22RE','Thermal Refrigerated                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'24RE','Thermal Refrigerated                                        ',              20,              9},,.F.)
    o:TableData('EYG',{'2331','Thermal Refrigerated                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2030','Thermal Refrigerated                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2040','Thermal Refrigerated                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'4231','Thermal Refrigerated                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4230','Thermal Refrigerated                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4131','Thermal Refrigerated                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'4130','Thermal Refrigerated                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'40RE','Thermal Refrigerated                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'4040','Thermal Refrigerated                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'4031','Thermal Refrigerated                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'4030','Thermal Refrigerated                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'2230','Thermal Refrigerated                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'4531','Thermal Refrigerated                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4530','Thermal Refrigerated                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'L5R0','Thermal Refrigerated                                        ',              45,              9.5},,.F.)
    o:TableData('EYG',{'L2RE','Thermal Refrigerated                                        ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L2R0','Thermal Refrigerated                                        ',              45,              8.5},,.F.)
    o:TableData('EYG',{'45RE','Thermal Refrigerated                                        ',              45,              9.5},,.F.)
    o:TableData('EYG',{'45R9','Thermal Refrigerated                                        ',              40,              9.5},,.F.)
    o:TableData('EYG',{'4243','Thermal Refrigerated                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4240','Thermal Refrigerated                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'2132','Thermal Refrigerated                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2131','Thermal Refrigerated                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2130','Thermal Refrigerated                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'20RE','Thermal Refrigerated                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'20R0','Thermal Refrigerated                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2043','Thermal Refrigerated                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2042','Thermal Refrigerated                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2041','Thermal Refrigerated                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2242','Thermal Refrigerated                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2240','Thermal Refrigerated                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2231','Thermal Refrigerated                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2031','Thermal Refrigerated                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'L5RE','Thermal Refrigerated                                        ',              45,              9.5},,.F.)
    o:TableData('EYG',{'4330','Thermal Refrigerated                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'44RE','Thermal Refrigerated                                        ',              40,              9},,.F.)
    o:TableData('EYG',{'4340','Thermal Refrigerated                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42RE','Thermal Refrigerated                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'2330','Thermal Refrigerated                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22H1','Thermal Refrigerated/Heated                                 ',              20,              8.5},,.F.)
    o:TableData('EYG',{'44H1','Thermal Refrigerated/Heated                                 ',              40,              9},,.F.)
    o:TableData('EYG',{'44H0','Thermal Refrigerated/Heated                                 ',              40,              9},,.F.)
    o:TableData('EYG',{'4333','Thermal Refrigerated/Heated                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4332','Thermal Refrigerated/Heated                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'24RT','Thermal Refrigerated/Heated                                 ',              20,              9},,.F.)
    o:TableData('EYG',{'24RS','Thermal Refrigerated/Heated                                 ',              20,              9},,.F.)
    o:TableData('EYG',{'24R3','Thermal Refrigerated/Heated                                 ',              20,              9},,.F.)
    o:TableData('EYG',{'24R2','Thermal Refrigerated/Heated                                 ',              20,              9},,.F.)
    o:TableData('EYG',{'24R1','Thermal Refrigerated/Heated                                 ',              20,              9},,.F.)
    o:TableData('EYG',{'45H1','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'45H0','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'4432','Thermal Refrigerated/Heated                                 ',              40,              9},,.F.)
    o:TableData('EYG',{'42R0','Thermal Refrigerated/Heated                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42HR','Thermal Refrigerated/Heated                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42HI','Thermal Refrigerated/Heated                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42H2','Thermal Refrigerated/Heated                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42H1','Thermal Refrigerated/Heated                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4232','Thermal Refrigerated/Heated                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42RT','Thermal Refrigerated/Heated                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'22RT','Thermal Refrigerated/Heated                                 ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22HR','Thermal Refrigerated/Heated                                 ',              20,              8.5},,.F.)
    o:TableData('EYG',{'L5RT','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'45RT','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'45H2','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'4533','Thermal Refrigerated/Heated                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4532','Thermal Refrigerated/Heated                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'L5HR','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'L5HI','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'L5H2','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'L5H1','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'L5H0','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'L2RT','Thermal Refrigerated/Heated                                 ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L2RS','Thermal Refrigerated/Heated                                 ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L2R3','Thermal Refrigerated/Heated                                 ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L2R2','Thermal Refrigerated/Heated                                 ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L2R1','Thermal Refrigerated/Heated                                 ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L2HR','Thermal Refrigerated/Heated                                 ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L2HI','Thermal Refrigerated/Heated                                 ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L2H2','Thermal Refrigerated/Heated                                 ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L2H1','Thermal Refrigerated/Heated                                 ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L2H0','Thermal Refrigerated/Heated                                 ',              45,              8.5},,.F.)
    o:TableData('EYG',{'9532','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'45RS','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'45RC','Thermal Refrigerated/Heated                                 ',              40,              9.5},,.F.)
    o:TableData('EYG',{'45R3','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'45R2','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'45R0','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'45HR','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'45HI','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'4132','Thermal Refrigerated/Heated                                 ',              40,              8},,.F.)
    o:TableData('EYG',{'40RT','Thermal Refrigerated/Heated                                 ',              40,              8},,.F.)
    o:TableData('EYG',{'40RS','Thermal Refrigerated/Heated                                 ',              40,              8},,.F.)
    o:TableData('EYG',{'40R3','Thermal Refrigerated/Heated                                 ',              40,              8},,.F.)
    o:TableData('EYG',{'40R2','Thermal Refrigerated/Heated                                 ',              40,              8},,.F.)
    o:TableData('EYG',{'40R1','Thermal Refrigerated/Heated                                 ',              40,              8},,.F.)
    o:TableData('EYG',{'40R0','Thermal Refrigerated/Heated                                 ',              40,              8},,.F.)
    o:TableData('EYG',{'40HR','Thermal Refrigerated/Heated                                 ',              40,              8},,.F.)
    o:TableData('EYG',{'40HI','Thermal Refrigerated/Heated                                 ',              40,              8},,.F.)
    o:TableData('EYG',{'40H2','Thermal Refrigerated/Heated                                 ',              40,              8},,.F.)
    o:TableData('EYG',{'40H1','Thermal Refrigerated/Heated                                 ',              40,              8},,.F.)
    o:TableData('EYG',{'40H0','Thermal Refrigerated/Heated                                 ',              40,              8},,.F.)
    o:TableData('EYG',{'4032','Thermal Refrigerated/Heated                                 ',              40,              8},,.F.)
    o:TableData('EYG',{'22R0','Thermal Refrigerated/Heated                                 ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2232','Thermal Refrigerated/Heated                                 ',              20,              8.5},,.F.)
    o:TableData('EYG',{'20R3','Thermal Refrigerated/Heated                                 ',              20,              8},,.F.)
    o:TableData('EYG',{'20R2','Thermal Refrigerated/Heated                                 ',              20,              8},,.F.)
    o:TableData('EYG',{'20R1','Thermal Refrigerated/Heated                                 ',              20,              8},,.F.)
    o:TableData('EYG',{'20HR','Thermal Refrigerated/Heated                                 ',              20,              8},,.F.)
    o:TableData('EYG',{'20HI','Thermal Refrigerated/Heated                                 ',              20,              8},,.F.)
    o:TableData('EYG',{'20H2','Thermal Refrigerated/Heated                                 ',              20,              8},,.F.)
    o:TableData('EYG',{'20H1','Thermal Refrigerated/Heated                                 ',              20,              8},,.F.)
    o:TableData('EYG',{'20H0','Thermal Refrigerated/Heated                                 ',              20,              8},,.F.)
    o:TableData('EYG',{'44RT','Thermal Refrigerated/Heated                                 ',              40,              9},,.F.)
    o:TableData('EYG',{'20RT','Thermal Refrigerated/Heated                                 ',              20,              8},,.F.)
    o:TableData('EYG',{'20RS','Thermal Refrigerated/Heated                                 ',              20,              8},,.F.)
    o:TableData('EYG',{'44RS','Thermal Refrigerated/Heated                                 ',              40,              9},,.F.)
    o:TableData('EYG',{'44R3','Thermal Refrigerated/Heated                                 ',              40,              9},,.F.)
    o:TableData('EYG',{'44R2','Thermal Refrigerated/Heated                                 ',              40,              9},,.F.)
    o:TableData('EYG',{'44R1','Thermal Refrigerated/Heated                                 ',              40,              9},,.F.)
    o:TableData('EYG',{'44R0','Thermal Refrigerated/Heated                                 ',              40,              9},,.F.)
    o:TableData('EYG',{'44HR','Thermal Refrigerated/Heated                                 ',              40,              9},,.F.)
    o:TableData('EYG',{'44HI','Thermal Refrigerated/Heated                                 ',              40,              9},,.F.)
    o:TableData('EYG',{'44H2','Thermal Refrigerated/Heated                                 ',              40,              9},,.F.)
    o:TableData('EYG',{'2032','Thermal Refrigerated/Heated                                 ',              20,              8},,.F.)
    o:TableData('EYG',{'L5RS','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'L5R3','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'L5R2','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'8532','Thermal Refrigerated/Heated                                 ',              35,              8.5},,.F.)
    o:TableData('EYG',{'24R0','Thermal Refrigerated/Heated                                 ',              20,              9},,.F.)
    o:TableData('EYG',{'24HR','Thermal Refrigerated/Heated                                 ',              20,              9},,.F.)
    o:TableData('EYG',{'24HI','Thermal Refrigerated/Heated                                 ',              20,              9},,.F.)
    o:TableData('EYG',{'24H2','Thermal Refrigerated/Heated                                 ',              20,              9},,.F.)
    o:TableData('EYG',{'24H1','Thermal Refrigerated/Heated                                 ',              20,              9},,.F.)
    o:TableData('EYG',{'24H0','Thermal Refrigerated/Heated                                 ',              20,              9},,.F.)
    o:TableData('EYG',{'2432','Thermal Refrigerated/Heated                                 ',              20,              9},,.F.)
    o:TableData('EYG',{'2332','Thermal Refrigerated/Heated                                 ',              20,              8.5},,.F.)
    o:TableData('EYG',{'42RS','Thermal Refrigerated/Heated                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42RC','Thermal Refrigerated/Heated                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42R9','Thermal Refrigerated/Heated                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42R3','Thermal Refrigerated/Heated                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42R2','Thermal Refrigerated/Heated                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'22RS','Thermal Refrigerated/Heated                                 ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22RC','Thermal Refrigerated/Heated                                 ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22R9','Thermal Refrigerated/Heated                                 ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22HI','Thermal Refrigerated/Heated                                 ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22R2','Thermal Refrigerated/Heated                                 ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22R3','Thermal Refrigerated/Heated                                 ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22H2','Thermal Refrigerated/Heated                                 ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2234','Thermal containers, Heated                                  ',              20,              8.5},,.F.)
    o:TableData('EYG',{'4535','Thermal/Heated                                              ',              40,              8.5},,.F.)
    o:TableData('EYG',{'8888','Uncontainerised                                             ',               0,                0},,.F.)
    o:TableData('EYG',{'45G4','Unrecognized container type                                 ',               0,                0},,.F.)
    o:TableData('EYG',{'4313','VENTILATED                                                  ',              40,                0},,.F.)
    o:TableData('EYG',{'28VH','Vented                                                      ',              20,              4.75},,.F.)
    o:TableData('EYG',{'28VO','Vented                                                      ',              20,              4.75},,.F.)
    o:TableData('EYG',{'22G0','20 Standard Dry                                             ',              20,              8.5},,.F.)
    o:TableData('EYG',{'42T0','40 Tank                                                     ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42U1','40 Open Top                                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42UP','40 Hard Top                                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'L5R1','45 Reefer High Cube                                         ',              45,              9.5},,.F.)
    o:TableData('EYG',{'42H0','40 Insulated (Conair)                                       ',              40,              8.5},,.F.)
EndIf

// EJA - 13/11/2017
o:TableStruct("SX3", {"X3_CAMPO", "X3_RELACAO"}, 2)
o:TableData(  "SX3" ,{"EEC_DTREC", "if(TYpe('M->EEC_DTREC')=='D',M->EEC_DTREC,CTOD(' / / '))"})

// NCF - 23/11/2017
o:TableStruct("SX3", {"X3_CAMPO"  ,   "X3_USADO" },2)
o:TableData(  "SX3" ,{"EYY_SEQEMB", TODOS_MODULOS})
o:TableData(  "SX3" ,{"EYY_D1ITEM", TODOS_MODULOS})
o:TableData(  "SX3" ,{"EYY_D1PROD", TODOS_MODULOS})

//THTS - 08/12/2017
o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_PICTURE"               },2)
o:TableData("SX3"  ,{"EG0_TEMPO" ,"@E 9,999,999.99999999"   })
o:TableData("SX3"  ,{"EG0_TDISCH","@E 9,999,999.99999999"   })
o:TableData("SX3"  ,{"EG0_TLOAD" ,"@E 9,999,999.99999999"   })

//THTS - 19/12/2017
o:TableStruct("SX3", {"X3_CAMPO", "X3_USADO" },2)
o:TableData(  "SX3" ,{"EE9_NF"  , TODOS_MODULOS})

// MPG - 16/01/2018
o:TableStruct("SX3", {"X3_CAMPO"   ,   "X3_USADO"   }, 2)
o:TableData(  "SX3" ,{"EEU_POSIC"  , TODOS_MODULOS  })

o:TableStruct("SIX",{"INDICE","ORDEM" ,"CHAVE"                                     ,"DESCRICAO"                    })
o:TableData(  "SIX",{"EEU"   ,"1"     ,"EEU_FILIAL+EEU_PREEMB+EEU_DESPES+EEU_POSIC","Embarque + Despesa + Posicao" })

o:TableStruct('SX2',{'X2_CHAVE','X2_UNICO'                                   })
o:TableData(  'SX2',{"EEU"     ,'EEU_FILIAL+EEU_PREEMB+EEU_DESPES+EEU_POSIC' })

// NCF - 15/02/2018 - Ajuste de USADO dos campos da tabela EYY (saldos de fim Específico Export.)
o:TableStruct("SX3", {"X3_CAMPO"   , "X3_USADO"    },2)
o:TableData(  "SX3" ,{"EYY_PREEMB" , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_SEQEMB" , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_RE"     , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_NFSAI"  , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_SERSAI" , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_NFENT"  , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_SERENT" , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_FORN"   , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_FOLOJA" , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_DESFOR" , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_PEDIDO" , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_SEQUEN" , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_FASE"   , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_QUANT"  , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_NROMEX" , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_DTMEX"  , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_D1ITEM" , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_CHVNFE" , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_SQFNFS" , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_D1PROD" , TODOS_MODULOS })

o:TableData(  "SX3" ,{"EE9_SEQED3" , TODOS_MODULOS })

//LRS - 10/04/2018
o:TableStruct("SX3", {"X3_CAMPO"  , "X3_USADO"    , "X3_RESERV"},2)
o:TableData(  "SX3" ,{"D1_SLDEXP" , TODOS_MODULOS ,  USO })

//LRS - 09/05/2018
o:TableStruct("SX7",{'X7_CAMPO' ,'X7_SEQUENC','X7_CHAVE'})
o:TableData('SX7',{'EE7_IMPORT' ,'001'       ,'xFilial("SA1")+M->EE7_IMPORT+M->EE7_IMLOJA' })
o:TableData('SX7',{'EE7_IMPORT' ,'010'       ,'xFilial("SA1")+M->EE7_IMPORT+M->EE7_IMLOJA' })

//THTS - 20/06/2018
o:TableStruct("SX3", {"X3_CAMPO"  , "X3_USADO"      ,"X3_VISUAL" ,"X3_WHEN"                                                 },2)
o:TableData(  "SX3" ,{"EXL_DTDSE" , TODOS_MODULOS   ,            ,                                                          })
o:TableData(  "SX3" ,{"EEC_NRODUE",                 ,"A"         ,                                                          })
o:TableData(  "SX3" ,{"EEC_NRORUC",                 ,            ,"!EasyGParam('MV_EEC0053',,.F.) .Or. Empty(M->EEC_NRODUE)"})

//EJA - 11/07/2018
o:TableStruct("SXB",{"XB_ALIAS", "XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"       	    ,"XB_DESCSPA"      		,"XB_DESCENG"   			,"XB_CONTEM"            ,"XB_WCONTEM"})
o:TableData("SXB"  ,{ "EC6EVE" , "1"     ,"01"    ,"DB"       ,"Eventos Imp/Exp"		,""		                ,"" 		                ,"EC6"                  ,            })
o:TableData("SXB"  ,{ "EC6EVE" , "2"     ,"01"    ,"01"       ,"Tipo Modulo + Ident."   ,""                		,""             			,""                     ,            })
o:TableData("SXB"  ,{ "EC6EVE" , "4"     ,"01"    ,"01"       ,"Ident. Campo"           ,""                		,""             			,"EC6_ID_CAM"           ,            })
o:TableData("SXB"  ,{ "EC6EVE" , "4"     ,"01"    ,"02"       ,"Descricao"              ,""                		,""             			,"EC6_DESC"             ,            })
o:TableData("SXB"  ,{ "EC6EVE" , "5"     ,"01"    ,""         ,""                	    ,""                		,""             			,"EC6->EC6_ID_CAM"      ,            })
o:TableData("SXB"  ,{ "EC6EVE" , "6"     ,"01"    ,""         ,""                	    ,""                		,""             			,"EC6ImpExp()"          ,            })

o:TableStruct("SX3"  ,{"X3_CAMPO"   ,"X3_F3" },2)
o:TableData  ("SX3"  ,{"YB_EVENT"   ,"EC6EVE"})

//LRS - 13/07/2018
o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_ORDEM" },2)
o:TableData(  "SX3",{"EE7_CONSIG" , 40        })
o:TableData(  "SX3",{"EE7_COLOJA" , 41        })
o:TableData(  "SX3",{"EE7_CONSDE" , 42        })

//CEO - 18/07/2018
o:TableStruct("SX3",{"X3_CAMPO", "X3_VALID"},2)
o:TableData ("SX3",{"EEM_TIPONF", "Pertence('12345') .And. If(FindFunction('NF400Valid'),NF400Valid(),.T.)"})

//LRS - 21/08/2018
o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_RESERV"},2)
o:TableData("SX3"  ,{"D1_SLDEXP" ,TAM+DEC    })

// MPG - 22/08/2018
o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_VALID"                                                                                                                        },2)
o:TableData("SX3"   ,{'EE7_FORN'  ,'AP100CRIT("EE7_FORN")   .AND. AP100Crit("EE7_MARCAC")'                                                                           })
o:TableData("SX3"   ,{'EE7_FOLOJA','AP100CRIT("EE7_FOLOJA") .AND. AP100Crit("EE7_MARCAC")'                                                                           })
o:TableData("SX3"   ,{'EE7_EXPORT','AP100CRIT("EE7_EXPORT") .AND. AP100Crit("EE7_MARCAC")'                                                                           })
o:TableData("SX3"   ,{'EE7_EXLOJA','AP100CRIT("EE7_EXLOJA") .AND. AP100Crit("EE7_MARCAC")'                                                                           })
o:TableData("SX3"   ,{'EE7_BENEF' ,'AP100CRIT("EE7_BENEF")  .AND. AP100Crit("EE7_MARCAC")'                                                                           })
o:TableData("SX3"   ,{'EE7_BELOJA','AP100CRIT("EE7_BELOJA") .AND. AP100Crit("EE7_MARCAC")'                                                                           })
o:TableData("SX3"   ,{'EE8_FORN'  ,'AP100CRIT("EE8_FORN") .AND. AP100Crit("EE7_MARCAC")'                                                                             })
o:TableData("SX3"   ,{'EE8_FOLOJA','AP100CRIT("EE8_FOLOJA") .AND. AP100Crit("EE7_MARCAC")'                                                                           })
o:TableData("SX3"   ,{'EE8_FABR'  ,'AP100CRIT("EE8_FABR")   .AND. AP100Crit("EE7_MARCAC")'                                                                           })
o:TableData("SX3"   ,{'EE8_FALOJA','AP100CRIT("EE8_FALOJA") .AND. AP100Crit("EE7_MARCAC")'                                                                           })
o:TableData("SX3"   ,{'EE7_IMPORT','AP100CRIT("EE7_IMPORT") .AND. AP100Crit("EE7_MARCAC")'                                                                           })
o:TableData("SX3"   ,{'EE7_IMLOJA','AP100CRIT("EE7_IMLOJA") .AND. AP100Crit("EE7_MARCAC")'                                                                           })
o:TableData("SX3"   ,{'EE7_CLIENT','AP100CRIT("EE7_CLIENT") .AND. AP100Crit("EE7_MARCAC")'                                                                           })
o:TableData("SX3"   ,{'EE7_CLLOJA','AP100CRIT("EE7_CLLOJA") .AND. AP100Crit("EE7_MARCAC")'                                                                           })
o:TableData("SX3"   ,{'EE7_CONSIG','AP100CRIT("EE7_CONSIG") .AND. AP100Crit("EE7_MARCAC")'                                                                           })
o:TableData("SX3"   ,{'EE7_COLOJA','AP100CRIT("EE7_COLOJA") .AND. AP100Crit("EE7_MARCAC")'                                                                           })
o:TableData("SX3"   ,{'EEN_IMPORT','AP100CRIT("EEN_IMPORT") .And. AP100NotiExist()'                                                                                  })
o:TableData("SX3"   ,{'EEN_IMLOJA','AP100CRIT("EEN_IMLOJA") .And. AP100NotiExist()'                                                                                  })

o:TableStruct("SX7",{"X7_CAMPO"  ,"X7_SEQUENC","X7_REGRA"                                                                                            ,"X7_CDOMIN" ,"X7_TIPO","X7_SEEK","X7_ALIAS","X7_ORDEM","X7_CHAVE"                                                                                            ,"X7_CONDIC"                               ,"X7_PROPRI"},1)
o:TableData("SX7"  ,{'EE7_FORN'  ,'001'       ,'AVGatilho(M->EE7_FORN  ,"SA2","2|3")'                                                                ,'EE7_FOLOJA','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,'!IsInCallStack("CONPAD1")'               ,'S'        })
o:TableData("SX7"  ,{'EE7_FORN'  ,'002'       ,'SA2->A2_NOME'                                                                                        ,'EE7_FORNDE','P'      ,'S'      ,'SA2'     ,'1'       ,'XFILIAL("SA2")+M->EE7_FORN+M->EE7_FOLOJA'                                                            ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_FOLOJA','001'       ,'IF(!EMPTY(M->EE7_FOLOJA),SA2->A2_NOME,"")'                                                           ,'EE7_FORNDE','P'      ,'S'      ,'SA2'     ,'1'       ,'XFILIAL("SA2")+M->EE7_FORN+M->EE7_FOLOJA'                                                            ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_EXPORT','001'       ,'AVGatilho(M->EE7_EXPORT,"SA2","3|4")'                                                                ,'EE7_EXLOJA','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_EXPORT','002'       ,'IF(!EMPTY(M->EE7_EXPORT),SA2->A2_NOME,"")'                                                           ,'EE7_EXPODE','P'      ,'S'      ,'SA2'     ,'1'       ,'XFILIAL("SA2")+M->EE7_EXPORT+IF(!EMPTY(M->EE7_EXLOJA),M->EE7_EXLOJA,"")'                             ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_EXLOJA','001'       ,'IF(!EMPTY(M->EE7_EXLOJA),SA2->A2_NOME,"")'                                                           ,'EE7_EXPODE','P'      ,'S'      ,'SA2'     ,'1'       ,'XFILIAL("SA2")+M->EE7_EXPORT+M->EE7_EXLOJA'                                                          ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_BENEF' ,'001'       ,'AVGatilho(M->EE7_BENEF ,"SA2","3|5")'                                                                ,'EE7_BELOJA','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,'!IsInCallStack("CONPAD1")'               ,'S'        })
o:TableData("SX7"  ,{'EE7_BENEF' ,'002'       ,'IF(!EMPTY(M->EE7_BENEF),SA2->A2_NOME,"")'                                                            ,'EE7_BENEDE','P'      ,'S'      ,'SA2'     ,'1'       ,'XFILIAL("SA2")+M->EE7_BENEF+M->EE7_BELOJA'                                                           ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_BENEF' ,'003'       ,'IF(!EMPTY(M->EE7_BENEF),EECMEND("SA2",1,M->EE7_BENEF+M->EE7_BELOJA,.T.,AvSx3("EE7_END2BE",3),2),"")' ,'EE7_END2BE','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_BELOJA','001'       ,'IF(!EMPTY(M->EE7_BELOJA),SA2->A2_NOME,"")'                                                           ,'EE7_BENEDE','P'      ,'S'      ,'SA2'     ,'1'       ,'XFILIAL("SA2")+M->EE7_BENEF+M->EE7_BELOJA'                                                           ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_BELOJA','002'       ,'IF(!EMPTY(M->EE7_BENEF),EECMEND("SA2",1,M->EE7_BENEF+M->EE7_BELOJA,.T.,AvSx3("EE7_ENDBEN",3),1),"")' ,'EE7_ENDBEN','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_BELOJA','003'       ,'IF(!EMPTY(M->EE7_BENEF),EECMEND("SA2",1,M->EE7_BENEF,.T.,AvSx3("EE7_END2BE",3),2),"")'               ,'EE7_END2BE','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE8_FORN'  ,'001'       ,'AVGatilho(M->EE8_FORN  ,"SA2","2|3")'                                                                ,'EE8_FOLOJA','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,'!IsInCallStack("CONPAD1")'               ,'S'        })
o:TableData("SX7"  ,{'EE8_FABR'  ,'001'       ,'AVGatilho(M->EE8_FABR  ,"SA2","1|3")'                                                                ,'EE8_FALOJA','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,'!IsInCallStack("CONPAD1")'               ,'S'        })
o:TableData("SX7"  ,{'EE7_IMPORT','001'       ,'AVGatilho(M->EE7_IMPORT,"SA1","1|4")'                                                                ,'EE7_IMLOJA','P'      ,'N'      ,''        ,'0'       ,'xFilial("SA1")+M->EE7_IMPORT+M->EE7_IMLOJA'                                                          ,'!IsInCallStack("CONPAD1")'               ,'S'        })
o:TableData("SX7"  ,{'EE7_IMPORT','002'       ,'AP102ViaTrans()'                                                                                     ,'EE7_VIA'   ,'P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,'AP102ViaTrans(.T.)'                      ,'S'        })
o:TableData("SX7"  ,{'EE7_IMPORT','003'       ,'AP100Import()'                                                                                       ,'EE7_VALCOM','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_IMPORT','004'       ,'IF(!EMPTY(SA1->A1_CONDPAG),SA1->A1_CONDPAG,M->EE7_CONDPA)'                                           ,'EE7_CONDPA','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_IMPORT','005'       ,'IF(!EMPTY(SA1->A1_CONDPAG),SA1->A1_DIASPAG,M->EE7_DIASPA)'                                           ,'EE7_DIASPA','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_IMPORT','006'       ,'EECMEND("SA1",1,M->EE7_IMPORT+M->EE7_IMLOJA,.T.,AvSx3("EE7_ENDIMP",3),1)'                            ,'EE7_ENDIMP','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_IMPORT','007'       ,'EECMEND("SA1",1,M->EE7_IMPORT+M->EE7_IMLOJA,.T.,AvSx3("EE7_END2IM",3),2)'                            ,'EE7_END2IM','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_IMPORT','008'       ,'POSICIONE("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_IDIOMA")'                                          ,'EE7_IDIOMA','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,'AP102CondGat()'                          ,'S'        })
o:TableData("SX7"  ,{'EE7_IMPORT','009'       ,'AP100FobImport("EE7_INCOTE")'                                                                        ,'EE7_INCOTE','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,'Empty(M->EE7_INCOTE)'                    ,'S'        })
o:TableData("SX7"  ,{'EE7_IMPORT','010'       ,'SA1->A1_NOME'                                                                                        ,'EE7_IMPODE','P'      ,'S'      ,'SA1'     ,'1'       ,'xFilial("SA1")+M->EE7_IMPORT+M->EE7_IMLOJA'                                                          ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_IMLOJA','001'       ,'SA1->A1_NOME'                                                                                        ,'EE7_IMPODE','P'      ,'S'      ,'SA1'     ,'1'       ,'XFILIAL("SA1")+M->EE7_IMPORT+M->EE7_IMLOJA'                                                          ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_IMLOJA','002'       ,'AP100Import()'                                                                                       ,'EE7_VALCOM','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_IMLOJA','003'       ,'IF(!EMPTY(SA1->A1_CONDPAG),SA1->A1_CONDPAG,M->EE7_CONDPA)'                                           ,'EE7_CONDPA','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_IMLOJA','004'       ,'IF(!EMPTY(SA1->A1_CONDPAG),SA1->A1_DIASPAG,M->EE7_DIASPA)'                                           ,'EE7_DIASPA','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_IMLOJA','005'       ,'EECMEND("SA1",1,M->EE7_IMPORT+M->EE7_IMLOJA,.T.,AvSx3("EE7_ENDIMP",3),1)'                            ,'EE7_ENDIMP','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_IMLOJA','006'       ,'EECMEND("SA1",1,M->EE7_IMPORT+M->EE7_IMLOJA,.T.,AvSx3("EE7_END2IM",3),2)'                            ,'EE7_END2IM','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_IMLOJA','007'       ,'POSICIONE("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_IDIOMA")'                                          ,'EE7_IDIOMA','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,'!Empty(SA1->A1_PAIS)'                    ,'S'        })
o:TableData("SX7"  ,{'EE7_IMLOJA','008'       ,'AP100FobImport("EE7_INCOTE")'                                                                        ,'EE7_INCOTE','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,'Empty(M->EE7_INCOTE)'                    ,'S'        })
o:TableData("SX7"  ,{'EE7_IMLOJA','009'       ,'AP100FobImport("EE7_INCOTE")'                                                                        ,'EE7_INCOTE','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,'Empty(M->EE7_INCOTE)'                    ,'S'        })
o:TableData("SX7"  ,{'EE7_CLIENT','001'       ,'AVGatilho(M->EE7_CLIENT,"SA1")'                                                                      ,'EE7_CLLOJA','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,'!IsInCallStack("CONPAD1")'               ,'S'        })
o:TableData("SX7"  ,{'EE7_CLIENT','002'       ,'IF(!EMPTY(M->EE7_CLIENT),SA1->A1_NOME,"")'                                                           ,'EE7_CLIEDE','P'      ,'S'      ,'SA1'     ,'1'       ,'XFILIAL("SA1")+M->EE7_CLIENT+M->EE7_CLLOJA'                                                          ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_CLLOJA','001'       ,'IF(!EMPTY(M->EE7_CLLOJA),SA1->A1_NOME,"")'                                                           ,'EE7_CLIEDE','P'      ,'S'      ,'SA1'     ,'1'       ,'XFILIAL("SA1")+M->EE7_CLIENT+M->EE7_CLLOJA'                                                          ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_CONSIG','001'       ,'AVGatilho(M->EE7_CONSIG,"SA1","2|4")'                                                                ,'EE7_COLOJA','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,'!IsInCallStack("CONPAD1")'               ,'S'        })
o:TableData("SX7"  ,{'EE7_CONSIG','002'       ,'IF(!EMPTY(M->EE7_CONSIG),SA1->A1_NOME,"")'                                                           ,'EE7_CONSDE','P'      ,'S'      ,'SA1'     ,'1'       ,'XFILIAL("SA1")+M->EE7_CONSIG+IF(!EMPTY(M->EE7_COLOJA),M->EE7_COLOJA,"")'                             ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_COLOJA','001'       ,'IF(!EMPTY(M->EE7_COLOJA),SA1->A1_NOME,"")'                                                           ,'EE7_CONSDE','P'      ,'S'      ,'SA1'     ,'1'       ,'XFILIAL("SA1")+M->EE7_CONSIG+IF(!EMPTY(M->EE7_COLOJA),M->EE7_COLOJA,"")'                             ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EEN_IMPORT','001'       ,'AVGatilho(M->EEN_IMPORT,"SA1","3|4")'                                                                ,'EEN_IMLOJA','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,'!IsInCallStack("CONPAD1")'               ,'S'        })
o:TableData("SX7"  ,{'EEN_IMPORT','002'       ,'SA1->A1_NOME'                                                                                        ,'EEN_IMPODE','P'      ,'S'      ,'SA1'     ,'1'       ,'XFILIAL("SA1")+M->EEN_IMPORT+M->EEN_IMLOJA'                                                          ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EEN_IMPORT','003'       ,'EECMEND("SA1",1,M->EEN_IMPORT+M->EEN_IMLOJA,.T.,AvSx3("EEN_ENDIMP",3),1)'                            ,'EEN_ENDIMP','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EEN_IMPORT','004'       ,'EECMEND("SA1",1,M->EEN_IMPORT+M->EEN_IMLOJA,.T.,AvSx3("EEN_END2IM",3),2)'                            ,'EEN_END2IM','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EEN_IMLOJA','001'       ,'SA1->A1_NOME'                                                                                        ,'EEN_IMPODE','P'      ,'S'      ,'SA1'     ,'1'       ,'XFILIAL("SA1")+M->EEN_IMPORT+M->EEN_IMLOJA'                                                          ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EEN_IMLOJA','002'       ,'EECMEND("SA1",1,M->EEN_IMPORT+M->EEN_IMLOJA,.T.,AvSx3("EEN_ENDIMP",3),1)'                            ,'EEN_ENDIMP','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EEN_IMLOJA','003'       ,'EECMEND("SA1",1,M->EEN_IMPORT+M->EEN_IMLOJA,.T.,AvSx3("EEN_END2IM",3),2)'                            ,'EEN_END2IM','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })

//THTS - 21/08/2018 - Gatilhos para os campos de loja do Embarque
o:TableStruct("SX7" ,{"X7_CAMPO"     ,"X7_SEQUENC","X7_REGRA"                            ,"X7_CDOMIN" ,"X7_TIPO","X7_SEEK","X7_ALIAS","X7_ORDEM","X7_CHAVE","X7_CONDIC"             ,"X7_PROPRI"})
o:TableData("SX7"   ,{"EEC_IMPORT"   ,"001"       ,"AVGatilho(M->EEC_IMPORT,'SA1','1|4')","EEC_IMLOJA","P"      ,"N"      ,""        ,""        ,""        ,'!IsInCallStack("CONPAD1")'                      ,"S"        })
o:TableData("SX7"   ,{"EEC_FORN"     ,"001"       ,"AVGatilho(M->EEC_FORN,'SA2','2|3')"  ,"EEC_FOLOJA","P"      ,"N"      ,""        ,""        ,""        ,'!IsInCallStack("CONPAD1")'                      ,"S"        })
o:TableData("SX7"   ,{"EEC_FORN"     ,"002"       ,"SA2->A2_NOME"                        ,"EEC_FORNDE","P"      ,"N"      ,""        ,""        ,""        ,"!Empty(SA2->A2_NOME)"  ,"S"        })
o:TableData("SX7"   ,{"EEC_CONSIG"   ,"001"       ,"AVGatilho(M->EEC_CONSIG,'SA1','2|4')","EEC_COLOJA","P"      ,"N"      ,""        ,""        ,""        ,'!IsInCallStack("CONPAD1")'                      ,"S"        })
o:TableData("SX7"   ,{"EEC_BENEF"    ,"001"       ,"AVGatilho(M->EEC_BENEF,'SA2','3|5')" ,"EEC_BELOJA","P"      ,"N"      ,""        ,""        ,""        ,'!IsInCallStack("CONPAD1")'                      ,"S"        })
o:TableData("SX7"   ,{"EEC_CLIENT"   ,"001"       ,"AVGatilho(M->EEC_CLIENT,'SA1')"      ,"EEC_CLLOJA","P"      ,"N"      ,""        ,""        ,""        ,'!IsInCallStack("CONPAD1")'                      ,"S"        })
o:TableData("SX7"   ,{"EEC_EXPORT"   ,"001"       ,"AVGatilho(M->EEC_EXPORT,'SA2','3|4')","EEC_EXLOJA","P"      ,"N"      ,""        ,""        ,""        ,'!IsInCallStack("CONPAD1")'                      ,"S"        })
o:TableData("SX7"   ,{"EE9_FORN"     ,"001"       ,"AVGatilho(M->EE9_FORN,'SA2','2|3')"  ,"EE9_FOLOJA","P"      ,"N"      ,""        ,""        ,""        ,'!IsInCallStack("CONPAD1")'                      ,"S"        })
o:TableData("SX7"   ,{"EE9_FABR"     ,"001"       ,"AVGatilho(M->EE9_FABR,'SA2','1|3')"  ,"EE9_FALOJA","P"      ,"N"      ,""        ,""        ,""        ,'!IsInCallStack("CONPAD1")'                      ,"S"        })
o:TableData("SX7"   ,{"EE9_CODUE"    ,"001"       ,"AVGatilho(M->EE9_CODUE,'SA2')"       ,"EE9_LOJUE" ,"P"      ,"N"      ,""        ,""        ,""        ,'!IsInCallStack("CONPAD1")'                      ,"S"        })
o:TableData("SX7"   ,{"EYU_FABR"     ,"001"       ,"AVGatilho(M->EYU_FABR,'SA2','1|3')"  ,"EYU_FA_LOJ","P"      ,"N"      ,""        ,""        ,""        ,'!IsInCallStack("CONPAD1")'                      ,"S"        })
o:TableData("SX7"   ,{"EYU_FABR"     ,"004"       ,"SA2->A2_NREDUZ"                      ,"EYU_FA_DES","P"      ,"N"      ,""        ,""        ,""        ,"!Empty(SA2->A2_NREDUZ)","S"        })
o:DelTableData('SX7',{'EE9_COD_I '  ,'007'       ,""                                    ,""          ,""       ,""       ,""        ,""        ,""        ,""                      ,""         })

o:TableStruct("SX3",{"X3_CAMPO"     ,"X3_VALID" },2)
o:TableData('SX3'  ,{'EEC_IMLOJA'   ,'AE100CRIT("EEC_IMLOJA") .And. AE100Crit("EEC_MARCAC")'})
o:TableData('SX3'  ,{'EEC_FOLOJA'   ,'AE100CRIT("EEC_FOLOJA") .And. AE100Crit("EEC_MARCAC")'})
o:TableData('SX3'  ,{'EEC_COLOJA'   ,'AE100CRIT("EEC_COLOJA")'})
o:TableData('SX3'  ,{'EEC_BELOJA'   ,'AE100CRIT("EEC_BELOJA")'})
o:TableData('SX3'  ,{'EEC_CLLOJA'   ,'AE100CRIT("EEC_CLLOJA")'})
o:TableData('SX3'  ,{'EEC_EXPORT'   ,'AE100CRIT("EEC_EXPORT") .AND. AE100Crit("EEC_MARCAC")'})
o:TableData('SX3'  ,{'EEC_EXLOJA'   ,'AE100CRIT("EEC_EXLOJA") .And. AE100Crit("EEC_MARCAC")'})
o:TableData('SX3'  ,{'EE9_FOLOJA'   ,'AE100CRIT("EE9_FOLOJA")'})
o:TableData('SX3'  ,{'EE9_FALOJA'   ,'AE100CRIT("EE9_FALOJA")'})
o:TableData('SX3'  ,{'EE9_CODUE'    ,'AE100CRIT("EE9_CODUE")'})
o:TableData('SX3'  ,{'EE9_LOJUE'    ,'AE100CRIT("EE9_LOJUE")'})
o:TableData('SX3'  ,{'EYU_FABR'     ,'AE100CRIT("EYU_FABR")'})
o:TableData('SX3'  ,{'EYU_FA_LOJ'   ,'AE100CRIT("EYU_FA_LOJ")'})

//LRS - 30/08/208
o:TableStruct("SX6",{"X6_FIL"   ,"X6_VAR"     ,"X6_TIPO","X6_DESCRIC"                                       ,"X6_DSCSPA" ,"X6_DSCENG" ,"X6_DESC1"                                           ,"X6_DSCSPA1" ,"X6_DSCENG1","X6_DESC2"                ,"X6_DSCSPA2","X6_DSCENG2","X6_CONTEUD","X6_CONTSPA","X6_CONTENG","X6_PROPRI","X6_PYME","X6_VALID", "X6_INIT", "X6_DEFPOR", "X6_DEFSPA", "X6_DEFENG"})
o:TableData("SX6"  ,{""         ,"MV_EEC0056" ,"L"      ,"Parâmetro utilizado para indicar se a comissão   ",""          ,""          ,"conta gráfica será enviada como desconto na baixa " ,            ,             ,"do título a receber  "   ,""          ,""          ,".F."       ,            ,            ,"S"        ,"S"      ,""        , ""       , ""         , ""         , ""         })

//THTS - 28/08/2018
o:TableStruct("SX7" ,{"X7_CAMPO"     ,"X7_SEQUENC","X7_REGRA"   ,"X7_CDOMIN" ,"X7_TIPO","X7_SEEK","X7_ALIAS","X7_ORDEM","X7_CHAVE","X7_CONDIC"             ,"X7_PROPRI"})
o:TableData("SX7"   ,{"EE9_COD_I"    ,"005"       ,"SB1->B1_QE" ,"EE9_QE"    ,"P"      ,"N"      ,""        ,""        ,""        ,"Empty(M->EE9_QE)"      ,"S"        })

//CEO - 03/09/2018
o:TableStruct("SXB"  ,{"XB_ALIAS"   , "XB_TIPO" , "XB_SEQ"  , "XB_COLUNA"   ,"XB_CONTEM"})
o:TableData  ("SXB"  ,{"AVE005"     , "6"       , "01"      , ""            ,"(LEFT(SA2->A2_ID_FBFN,1) $ '2/3') .OR. Empty(SA2->A2_ID_FBFN)" })

o:TableStruct("SX3"  ,{"X3_CAMPO" ,"X3_F3" },2)
o:TableData  ("SX3"  ,{"EE8_FORN" ,"AVE005"})
o:TableData  ("SX3"  ,{"EE9_FORN" ,"AVE005"})
o:TableData  ("SX3"  ,{"EE8_FABR" ,"AVE014"})
o:TableData  ("SX3"  ,{"EE9_FABR" ,"AVE014"})

o:TableStruct("SXB",{"XB_ALIAS" , "XB_TIPO" , "XB_SEQ"  , "XB_COLUNA", "XB_DESCRI"          , "XB_DESCSPA"              , "XB_DESCENG"          , "XB_CONTEM"                                                       , "XB_WCONTEM"})
o:TableData  ("SXB",{ "AVE014"  , "1"       , "01"      , "DB"       , "Fabricantes"        , "Fabricantes"             , "Manufactures"        , "SA2"                                                             , })
o:TableData  ("SXB",{ "AVE014"  , "2"       , "01"      , "01"       , "Código + Loja"      , "Codigo + Tienda"         , "Code + Unit"         , ""                                                                , })
o:TableData  ("SXB",{ "AVE014"  , "2"       , "02"      , "02"       , "Razao Social + Loja", "Razon Social + Tienda"   , "Company Name + Unit" , ""                                                                , })
o:TableData  ("SXB",{ "AVE014"  , "3"       , "01"      , "01"       , "Cadastro Novo"      , "Incluye Nuevo"           , "Add New"             , "01"                                                              , })
o:TableData  ("SXB",{ "AVE014"  , "4"       , "01"      , "01"       , "Código"             , "Codigo"                  , "Code"                , "A2_COD"                                                          , })
o:TableData  ("SXB",{ "AVE014"  , "4"       , "01"      , "02"       , "Loja"               , "Tienda"                  , "Unit"                , "A2_LOJA"                                                         , })
o:TableData  ("SXB",{ "AVE014"  , "4"       , "01"      , "03"       , "Nome"               , "Nombre"                  , "Name"                , "SUBSTR(A2_NOME,1,30)"                                            , })
o:TableData  ("SXB",{ "AVE014"  , "4"       , "02"      , "01"       , "Nome"               , "Nombre"                  , "Name"                , "SUBSTR(A2_NOME,1,30)"                                            , })
o:TableData  ("SXB",{ "AVE014"  , "4"       , "02"      , "02"       , "Codigo"             , "Codigo"                  , "Manufacturer"        , "A2_COD"                                                          , })
o:TableData  ("SXB",{ "AVE014"  , "4"       , "02"      , "03"       , "Loja"               , "Tienda"                  , "Unit"                , "A2_LOJA"                                                         , })
o:TableData  ("SXB",{ "AVE014"  , "5"       , "01"      , ""         , ""                   , ""                        , ""                    , "SA2->A2_COD"                                                     , })
o:TableData  ("SXB",{ "AVE014"  , "5"       , "02"      , ""         , ""                   , ""                        , ""                    , "SA2->A2_LOJA"                                                    , })
o:TableData  ("SXB",{ "AVE014"  , "6"       , "01"      , ""         , ""                   , ""                        , ""                    , "(LEFT(SA2->A2_ID_FBFN,1) $ '1/3') .OR. Empty(SA2->A2_ID_FBFN)"   , })

o:TableStruct("EC6" , {"EC6_FILIAL"     , "EC6_TPMODU"  ,"EC6_ID_CAM"   ,"EC6_RECDES"	,"EC6_DESC"            , "EC6_IDENTC"}, 1)
o:TableData("EC6"   , {xFilial("EC6")   , "EXPORT"      ,"603"          ,"1"	        ,"ADIANTAMENTO POS-EMB", ""          },,.F.)

o:TableStruct("SX3"  ,{"X3_CAMPO"   ,"X3_USADO"    },2)
o:TableData  ("SX3"  ,{"EE7_FREEMB" , TODOS_MODULOS})
o:TableData  ("SX3"  ,{"EEC_FREEMB" , TODOS_MODULOS})

If EE9->(FieldPos("EE9_LPCO")) > 0
    o:TableStruct("SX3"  ,{"X3_CAMPO" , "X3_USADO"     },2)
    o:TableData  ("SX3"  ,{"EE9_LPCO" , TODOS_MODULOS})
EndIf

o:TableStruct("SX3"  ,{"X3_CAMPO" , "X3_VISUAL", "X3_USADO",    "X3_RESERV"   },2)
o:TableData  ("SX3"  ,{"EEC_DTDUE", "A"        , TODOS_MODULOS, USO  })

//CEO - 17/10/2018
o:TableStruct ("SX3",{"X3_CAMPO", "X3_WHEN"},2)
o:TableData ("SX3"  ,{"EEM_NRNF", "AE101WHEN('EEM_NRNF')" })
o:TableData ("SX3"  ,{"EEM_SERIE", "AE101WHEN('EEM_SERIE')" })
o:TableData ("SX3"  ,{"EEM_DTNF",  "AE101WHEN('EEM_DTNF')" })   

// MPG - 26/10/2018 - CORREÇÃO DO CAMPO MOEDAEASY QUE NÃO APARECE NO CADASTRO DE BANCOS
o:TableStruct("SX3"  ,{"X3_CAMPO"  , "X3_USADO"     },2)
o:TableData  ("SX3"  ,{"A6_MOEEASY", TODOS_MODULOS  })

o:TableStruct("SX3"  ,{"X3_CAMPO"  ,"X3_FOLDER"  , "X3_USADO"     },2)
o:TableData  ("SX3"  ,{"EE8_DESCON", "1"         , TODOS_MODULOS  })
o:TableData  ("SX3"  ,{"EE9_DESCON", ""          , TODOS_MODULOS  })

//EJA - 07/11/2018
o:TableStruct("SX3",{"X3_CAMPO", "X3_PICTURE", "X3_RESERV"},2)
o:TableData  ("SX3",{"EL2_RE"  , ""          , TAM        })
o:TableData  ("SX3",{"EL7_RE"  , ""          , TAM        })

//THTS - 10/01/2019
o:TableStruct("SX3", {"X3_CAMPO",   "X3_USADO"}, 2)
o:TableData(  "SX3" ,{"EE8_GRADE", TODOS_MODULOS})

//MPG - 11/04/2019
o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_PICTURE"               },2)
o:TableData("SX3"  ,{"YD_DESTAQU" , '@R ###/###/###/###/###/###/###/###/###/###' })

//MFR 01/04/2019 OSSME-1772
o:TableStruct("SX3",{"X3_CAMPO"   , "X3_USADO" },2)
o:TableData("SX3"  ,{"EYO_LOCENT" , NAO_USADO   })

//MFR 11/04/2019 OSSME-2708
AAdd( aDados, { { 'SWB', 'SYE', 'WB_DT_CONT+WB_MOEDA', 'DTOS(YE_DATA)+YE_MOEDA' }, { { 'X9_EXPDOM', 'YE_DATA+YE_MOEDA' } } } ) 
//EngSX9117( aDados ) rotina não é mais executada e esta funcao estava sendo reportada nos débitos técnicos MFR 24/06/2021 OSSME-5986

o:TableStruct("SX3",{"X3_CAMPO"   , "X3_RESERV","X3_TIPO"},2)
o:TableData  ("SX3",{"EYY_VM_DES" , USO+TIPO   ,"C"})

//MPG - 29/05/2019 - OSSME-3046
o:TableStruct("SX3",{"X3_CAMPO"   , "X3_VALID"},2)
o:TableData  ("SX3",{"EEC_RECALF" , 'vazio() .OR. ExistCpo("SJA")' })
o:TableData  ("SX3",{"EEC_RECEMB" , 'vazio() .OR. ExistCpo("SJA")' })

//MPG - 29/05/2019 - OSSME-3046
o:TableStruct("SX3",{"X3_CAMPO"   , "X3_RESERV" },2)
o:TableData  ("SX3",{"EK1_LATDES" , USO+TAM+DEC })
o:TableData  ("SX3",{"EK1_LONDES" , USO+TAM+DEC })
o:TableData  ("SX3",{"EK1_TOTFOB" , USO+TAM+DEC })
o:TableData  ("SX3",{"EK1_VALCOM" , USO+TAM+DEC })
o:TableData  ("SX3",{"EK2_PERCOM" , USO+TAM+DEC })
o:TableData  ("SX3",{"EK2_PESNCM" , USO+TAM+DEC })
o:TableData  ("SX3",{"EK2_PRCINC" , USO+TAM+DEC })
o:TableData  ("SX3",{"EK2_PRCTOT" , USO+TAM+DEC })
o:TableData  ("SX3",{"EK2_PSLQUN" , USO+TAM+DEC })
o:TableData  ("SX3",{"EK2_QTDNCM" , USO+TAM+DEC })
o:TableData  ("SX3",{"EK2_SLDINI" , USO+TAM+DEC })
o:TableData  ("SX3",{"EK2_VLSCOB" , USO+TAM+DEC })
o:TableData  ("SX3",{"EK4_D2QTD"  , USO+TAM+DEC })
o:TableData  ("SX3",{"EK4_QUANT"  , USO+TAM+DEC })
o:TableData  ("SX3",{"EK6_QTUMIT" , USO+TAM+DEC })
o:TableData  ("SX3",{"EK6_QUANT"  , USO+TAM+DEC })
o:TableData  ("SX3",{"EK7_QTD"    , USO+TAM+DEC })
o:TableData  ("SX3",{"EK7_VALOR"  , USO+TAM+DEC })
o:TableData  ("SX3",{"EK7_VLSCOB" , USO+TAM+DEC })
o:TableData  ("SX3",{"EK8_QTD"    , USO+TAM+DEC })
o:TableData  ("SX3",{"EK8_VLNF"   , USO+TAM+DEC })
o:TableData  ("SX3",{"EWI_QTD"    , USO+TAM+DEC })
o:TableData  ("SX3",{"EWI_VLNF"   , USO+TAM+DEC })
o:TableData  ("SX3",{"EE9_SLDINI" , USO+TAM+DEC })

//THTS - 04/06/2019
o:TableStruct("SX7" ,{"X7_CAMPO"     ,"X7_SEQUENC","X7_REGRA"               ,"X7_CDOMIN" ,"X7_TIPO","X7_SEEK","X7_CONDIC"       ,"X7_PROPRI"})
o:TableData("SX7"   ,{"EEQ_DESCON"   ,"001"       ,"AF200VLFCam('M','LIQ')" ,"EEQ_VM_REC","P"      ,"N"      ,"!lFinanciamento" ,"S"        })
o:TableData("SX7"   ,{"EEQ_DESCON"   ,"003"       ,"AF200VLFCam('M','LIQ')" ,"EEQ_VLFCAM","P"      ,"N"      ,"!lFinanciamento" ,"S"        })

//MPG - 02/07/2019 - OSSME-3308
o:TableStruct("SX3",{"X3_CAMPO"   , "X3_RESERV" },2)
o:TableData  ("SX3",{"EE8_PSBRTO" , USO+TAM+DEC })

//NCF - 04/07/2019 - OSSME-2546
o:TableStruct("SX3",{"X3_CAMPO"   , "X3_WHEN" },2)
o:TableData  ("SX3",{"EEQ_MODAL" , "AF200W('EEQ_MODAL')" })

//MPG - 16/09/2019 - OSSME-3698
o:TableStruct("SX3",{"X3_CAMPO"   , "X3_RESERV" , "X3_INIBRW"},2)
o:TableData  ("SX3",{"EE7_VM_AMO" , TAM         , "IniBrwAmostra('EE7')" })
o:TableData  ("SX3",{"EEC_VM_AMO" , TAM         , "IniBrwAmostra('EEC')" })

//MFR 30/09/2019 OSSME-3309
o:TableStruct("SX3",{"X3_CAMPO"     ,"X3_VALID" },2)
o:TableData('SX3'  ,{'EE8_DESCON'   ,'(VAZIO() .OR. POSITIVO()) .AND. AP100CRIT("EE8_DESCON")'})

//RNLP - 30/09/2019
o:TableStruct("SX7" ,{"X7_CAMPO"     ,"X7_SEQUENC","X7_REGRA"               ,"X7_CDOMIN" ,"X7_TIPO","X7_SEEK",'X7_ALIAS' ,'X7_ORDEM' ,'X7_CHAVE'                    ,'X7_CONDIC' ,'X7_PROPRI'})
o:TableData("SX7"   ,{"EE8_POSIPI"   ,"001"       ,"SYD->YD_DESTAQU"        ,"EE8_DTQNCM","P"      ,"S"      ,"SYD"      ,3          ,'XFILIAL("SYD")+M->EE8_POSIPI','', 'S'    })
o:TableData("SX7"   ,{"EE9_POSIPI"   ,"001"       ,"SYD->YD_DESTAQU"        ,"EE9_DTQNCM","P"      ,"S"      ,"SYD"      ,3          ,'XFILIAL("SYD")+M->EE9_POSIPI','', 'S'    })

//RNLP - 30/09/2019 //ALTERAR TRIGGER SX3 para uso de gatilho
o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_TRIGGER"},2)
o:TableData("SX3"  ,{"EE8_POSIPI" , "S"        })
o:TableData("SX3"  ,{"EE9_POSIPI" , "S"        })

//RNLP - 30/10/2019 //ALTERAR INICIALIZADOR PADRAO PARA CHAMADA DA FUNCAO EECIniPad
o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_RELACAO"},2)
o:TableData("SX3"  ,{"EYY_COD_I" , "EECIniPad('EYY_COD_I')"        })

o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_VALID"},2)
o:TableData("SX3"  ,{"EE8_PRECO"  , 'AP100CRIT("EE8_PRECO") .AND. POSITIVO() .AND. EECVLEE8("EE8_PRECO") .AND. AP104GATPRECO(,.T.)'  }) 
o:TableData("SX3"  ,{"EE9_PRECO"  , 'POSITIVO().AND.EECVLEE9("EE9_PRECO") .And. AE100PrecoI() .AND. AP104GATPRECO(,.F.)'             })                                                                                                 
o:TableData("SX3"  ,{"EE9_UNPRC"  , 'Vazio() .Or. ExistCpo("SAH") .AND. AP104GATPRECO(, .F.)'                                        }) //NCF - 11/11/2019 - Compatibilidade com Atusx.

//NCF - 04/03/2020 - //Gatilhar o valor na moeda do banco ao alterar a paridade manualmente.
o:TableStruct("SX7",{'X7_CAMPO'   ,'X7_SEQUENC'  , 'X7_REGRA'                    ,'X7_CDOMIN'  ,'X7_TIPO' ,'X7_SEEK'  ,'X7_ALIAS' , 'X7_ORDEM' , 'X7_CHAVE' , 'X7_CONDIC' ,'X7_PROPRI'},1)
o:TableData("SX7"  ,{"EEQ_PRINBC" ,"001"         ,"M->EEQ_VLFCAM * M->EEQ_PRINBC",'EEQ_VLMBCO' ,'P'       ,'N'        ,           ,            ,            ,             ,"S"        }  )
o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_TRIGGER"},2)
o:TableData("SX3"  ,{"EEQ_PRINBC" , "S"        })

Return Nil

/*
Funcao                     : UPDEEC033
Parametros                 : Objeto de update PAI
Retorno                    : Nenhum
Objetivos                  : Atualização de dicionários e helps
Autor       			      : Maurício Frison
Data/Hora   			      : 18/03/2021
Data/Hora Ultima alteração :
Revisao                    :
Obs.                       :
*/
Function UPDEEC033(o)
    o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_ORDEM" },2)
    o:TableData  ("SX3",{"EEA_TIPCUS" ,"08"       })

Return nil



/*
Função     : AtuStatusDUE()
Objetivo   : Atualização do Status da DUE por filiais do sistema
Retorno    : 
Autor      : WFS - Wilsimar Fabrício da Silva
Data       : 26/05/2017
*/
Static Function AtuStatusDUE()
Local aSM0:= {}
Local nCont, cOldFilial

Begin Sequence

   If !AvFlags("DU-E")
      Break
   EndIf
   
   cOldFilial:= cFilAnt
   aSM0:= FWLoadSM0()
   
   For nCont:= 1 To Len(aSM0)
      If aSm0[nCont][1] == cEmpAnt
         cFilAnt:= aSm0[nCont][2]
         AtuStFilial(cFilAnt)
      EndIf
   Next

   cFilAnt:= cOldFilial
End Sequence
Return

/*
Função     : AtuStFilial()
Objetivo   : Query para atualização, por filial
Retorno    : 
Autor      : WFS - Wilsimar Fabrício da Silva
Data       : 26/05/2017
*/
Static Function AtuStFilial(cFil)
Local cQuery

   cQuery:= "Select R_E_C_N_O_ RECNO From " + RetSqlName("EEC") + " Where EEC_FILIAL = '" + cFil + "' And EEC_STTDUE = ''"
   If TcSrvType() <> "AS/400"
      cQuery += " And D_E_L_E_T_ <> '*'"
   EndIf

   cQuery:= ChangeQuery(cQuery)
   TcQuery cQuery Alias "TMPDUE" New

   TMPDUE->(DBGoTop())
   
   While TMPDUE->(!Eof())
      EEC->(DBGoTo(TMPDUE->(RECNO)))
   
      EEC->(RecLock("EEC", .F.))
      EEC->EEC_STTDUE:= DU400Status()
      EEC->(MsUnlock())
   
      TMPDUE->(DBSkip())      
   EndDo

   TMPDUE->(DBCloseArea())
Return
