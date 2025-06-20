#include "TOTVS.CH"

Class PLSMprBa3 from CenMapper

    Method New() Constructor

EndClass

Method New() Class PLSMprBa3
    _Super:new()

    aAdd(self:aFields,{"BA3_CODINT" ,"operator"})
    aAdd(self:aFields,{"BA3_CODEMP" ,"groupCompany"})
    aAdd(self:aFields,{"BA3_CONEMP" ,"companyContract"})
    aAdd(self:aFields,{"BA3_VERCON" ,"contractVersion"})
    aAdd(self:aFields,{"BA3_SUBCON" ,"subContract"})
    aAdd(self:aFields,{"BA3_VERSUB" ,"subContractVersion"})
    aAdd(self:aFields,{"BA3_NUMCON" ,"adhesionStatement"})
    aAdd(self:aFields,{"BA3_MATRIC" ,"registration"})
    aAdd(self:aFields,{"BA3_MATEMP" ,"registrationInCompany"})
    aAdd(self:aFields,{"BA3_MATANT" ,"formerRegistration"})
    aAdd(self:aFields,{"BA3_HORACN" ,"contractTime"})
    aAdd(self:aFields,{"BA3_COBNIV" ,"chargeThisLevel"})
    aAdd(self:aFields,{"BA3_VENCTO" ,"dueDate"})
    aAdd(self:aFields,{"BA3_DATBAS" ,"additionDate"})
    aAdd(self:aFields,{"BA3_PODREM" ,"allowReimburs"})
    aAdd(self:aFields,{"BA3_DATCIV" ,"adjustmentDate"})
    aAdd(self:aFields,{"BA3_MESREA" ,"adjustmentMonth"})
    aAdd(self:aFields,{"BA3_INDREA" ,"adjustmentIndex"})
    aAdd(self:aFields,{"BA3_CODCLI" ,"customerCode"})
    aAdd(self:aFields,{"BA3_LOJA" ,"storeCode"})
    aAdd(self:aFields,{"BA3_TIPOUS" ,"contractType"})
    aAdd(self:aFields,{"BA3_NATURE" ,"financialClassCode"})
    aAdd(self:aFields,{"BA3_CODFOR" ,"supplier"})
    aAdd(self:aFields,{"BA3_LOJFOR" ,"store"})
    aAdd(self:aFields,{"BA3_MOTBLO" ,"reasonForBlock"})
    aAdd(self:aFields,{"BA3_DATBLO" ,"blockDate"})
    aAdd(self:aFields,{"BA3_CODPLA" ,"planCode"})
    aAdd(self:aFields,{"BA3_VERSAO" ,"version"})
    aAdd(self:aFields,{"BA3_FORPAG" ,"paymentMode"})
    aAdd(self:aFields,{"BA3_TIPCON" ,"typeContract"})
    aAdd(self:aFields,{"BA3_SEGPLA" ,"planSegment"})
    aAdd(self:aFields,{"BA3_MODPAG" ,"paymentModality"})
    aAdd(self:aFields,{"BA3_FORCTX" ,"formOfCharAdmFee"})
    aAdd(self:aFields,{"BA3_TXUSU" ,"chargeFeeImmediately"})
    aAdd(self:aFields,{"BA3_FORCOP" ,"optionalCollectMode"})
    aAdd(self:aFields,{"BA3_AGMTFU" ,"payrollEmployeeRegistr"})
    aAdd(self:aFields,{"BA3_APLEI" ,"regulated"})
    aAdd(self:aFields,{"BA3_AGFTFU" ,"branchCode"})
    aAdd(self:aFields,{"BA3_VALSAL" ,"salary"})
    aAdd(self:aFields,{"BA3_ROTSAL" ,"salaryCalcRoutine"})
    aAdd(self:aFields,{"BA3_EQUIPE" ,"team"})
    aAdd(self:aFields,{"BA3_CODVEN" ,"salesRepresentative"})
    aAdd(self:aFields,{"BA3_ENDCOB" ,"collectionLocation"})
    aAdd(self:aFields,{"BA3_CEP" ,"zip"})
    aAdd(self:aFields,{"BA3_END" ,"address"})
    aAdd(self:aFields,{"BA3_NUMERO" ,"number"})
    aAdd(self:aFields,{"BA3_COMPLE" ,"complement"})
    aAdd(self:aFields,{"BA3_BAIRRO" ,"district"})
    aAdd(self:aFields,{"BA3_CODMUN" ,"cityCode"})
    aAdd(self:aFields,{"BA3_MUN" ,"city"})
    aAdd(self:aFields,{"BA3_ESTADO" ,"state"})
    aAdd(self:aFields,{"BA3_USUOPE" ,"operatorUserCode"})
    aAdd(self:aFields,{"BA3_DATCON" ,"dateOfTyping"})
    aAdd(self:aFields,{"BA3_HORCON" ,"timeOfTyping"})
    aAdd(self:aFields,{"BA3_GRPCOB" ,"collectionGroup"})
    aAdd(self:aFields,{"BA3_CODTDE" ,"coParticipationTable"})
    aAdd(self:aFields,{"BA3_DESMUN" ,"cityDescription"})
    aAdd(self:aFields,{"BA3_RGIMP" ,"importedRecord"})
    aAdd(self:aFields,{"BA3_DEMITI" ,"dismissed"})
    aAdd(self:aFields,{"BA3_DATDEM" ,"dismissalDate"})
    aAdd(self:aFields,{"BA3_MOTDEM" ,"reasonForDismissal"})
    aAdd(self:aFields,{"BA3_LIMATE" ,"attendanceLimit"})
    aAdd(self:aFields,{"BA3_ABRANG" ,"scope"})
    aAdd(self:aFields,{"BA3_INFCOB" ,"informCoverage"})
    aAdd(self:aFields,{"BA3_INFGCB" ,"informCoverageGroup"})
    aAdd(self:aFields,{"BA3_IMPORT" ,"importedFile"})
    aAdd(self:aFields,{"BA3_VALANT" ,"formerSystemValue"})
    aAdd(self:aFields,{"BA3_LETANT" ,"previousLetter"})
    aAdd(self:aFields,{"BA3_DATALT" ,"dateOfLastChange"})
    aAdd(self:aFields,{"BA3_COBRAT" ,"calcProRataCollection"})
    aAdd(self:aFields,{"BA3_RATMAI" ,"pRataExitFMajority"})
    aAdd(self:aFields,{"BA3_COBRET" ,"chargeRetroactive"})
    aAdd(self:aFields,{"BA3_DIARET" ,"retroactiveLimitDay"})
    aAdd(self:aFields,{"BA3_ULTCOB" ,"lastCollectDate"})
    aAdd(self:aFields,{"BA3_RATSAI" ,"chargeProRataOnOutflo"})
    aAdd(self:aFields,{"BA3_NUMCOB" ,"collectionNumber"})
    aAdd(self:aFields,{"BA3_ULREA" ,"lastAdjYearMonth"})
    aAdd(self:aFields,{"BA3_CARIMP" ,"printBooklet"})
    aAdd(self:aFields,{"BA3_PERMOV" ,"transactYearMonth"})
    aAdd(self:aFields,{"BA3_NIVFOR" ,"collectionModeLevel"})
    aAdd(self:aFields,{"BA3_NIVFTX" ,"adhesionFeeModeLevel"})
    aAdd(self:aFields,{"BA3_NIVFOP" ,"optionalFormLevel"})
    aAdd(self:aFields,{"BA3_OUTLAN" ,"otherEntries"})
    aAdd(self:aFields,{"BA3_MATFMB" ,"blockedFamilyRegistr"})
    aAdd(self:aFields,{"BA3_CODACO" ,"accomodationCode"})
    aAdd(self:aFields,{"BA3_TRAORI" ,"transferOrigin"})
    aAdd(self:aFields,{"BA3_TRADES" ,"transferDestination"})
    aAdd(self:aFields,{"BA3_ROTINA" ,"calculationRoutine"})
    aAdd(self:aFields,{"BA3_VALID" ,"validity"})
    aAdd(self:aFields,{"BA3_DATPLA" ,"planLastModificDate"})
    aAdd(self:aFields,{"BA3_DESLIG" ,"holderSeverance"})
    aAdd(self:aFields,{"BA3_DATDES" ,"holderSeveranceDate"})
    aAdd(self:aFields,{"BA3_LOTTRA" ,"transferLotNumber"})
    aAdd(self:aFields,{"BA3_BLOFAT" ,"blockBilling"})
    aAdd(self:aFields,{"BA3_CODRDA" ,"rdaFDescInMedProd"})
    aAdd(self:aFields,{"BA3_CODLAN" ,"debitEntryCode"})
    aAdd(self:aFields,{"BA3_TIPPAG" ,"codeOfPaymentMode"})
    aAdd(self:aFields,{"BA3_BCOCLI" ,"customerBank"})
    aAdd(self:aFields,{"BA3_AGECLI" ,"customerBranch"})
    aAdd(self:aFields,{"BA3_CTACLI" ,"customerAccount"})
    aAdd(self:aFields,{"BA3_LIMITE" ,"userDeadline"})
    aAdd(self:aFields,{"BA3_PORTAD" ,"operatorBank"})
    aAdd(self:aFields,{"BA3_AGEDEP" ,"operatorBranch"})
    aAdd(self:aFields,{"BA3_CTACOR" ,"operatorAccount"})
    aAdd(self:aFields,{"BA3_DESMEN" ,"monthlyFeeDiscount"})
    aAdd(self:aFields,{"BA3_CODVE2" ,"salesRepresent2Code"})
    aAdd(self:aFields,{"BA3_CONSID" ,"considerBlock"})
    aAdd(self:aFields,{"BA3_PADSAU" ,"comfortStandard"})
    aAdd(self:aFields,{"BA3_PLPOR" ,"portabilityOldPlan"})
    aAdd(self:aFields,{"BA3_AGLUT" ,"groupItensInvNfs"})
    aAdd(self:aFields,{"BA3_PACOOK" ,"indicateIfInstalOrNot"})
    aAdd(self:aFields,{"BA3_DIASIN" ,"nrOfDefaultDays"})
    aAdd(self:aFields,{"BA3_CODTES" ,"invoiceOutflowType"})
    aAdd(self:aFields,{"BA3_CODSB1" ,"erpProductCode"})
    aAdd(self:aFields,{"BA3_REEWEB" ,"solReimbPortalAsset"})
    aAdd(self:aFields,{"BA3_GRPFAM" ,"fieldTargetedToLink"})
    aAdd(self:aFields,{"BA3_TIPPGO" ,"typePaymment"})
    aAdd(self:aFields,{"BA3_UNDORG" ,"organizationalUnit"})
    aAdd(self:aFields,{"BA3_NOTB" ,"notifyBeneficiary"})
    aAdd(self:aFields,{"BA3_COMAUT" ,"automaticCompensation"})
    aAdd(self:aFields,{"BA3_TIPVIN" ,"linkType"})
    aAdd(self:aFields,{"BA3_CODRAS" ,"familyTrackingCode"})


Return self
