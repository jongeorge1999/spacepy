!      PROGRAM SD2
C
C     SHIELDOSE-2, VERSION 2.10, 28 APR 94.
C
C        S.M. SELTZER
C        NATIONAL INSTITUTE OF STANDARDS AND TECHNOLOGY
C        GAITHERSBURG, MD 20899
C        (301) 975-5552
C
C        IDET = 1, AL DETECTOR
C               2, GRAPHITE DETECTOR
C               3, SI DETECTOR
C               4, AIR DETECTOR
C               5, BONE DETECTOR
C               6, CALCIUM FLUORIDE DETECTOR
C               7, GALLIUM ARSENIDE DETECTOR
C               8, LITHIUM FLUORIDE DETECTOR
C               9, SILICON DIOXIDE DETECTOR
C              10, TISSUE DETECTOR
C              11, WATER DETECTOR
C
C        INUC = 1, NO NUCLEAR ATTENUATION FOR PROTONS IN AL
C               2, NUCLEAR ATTENUATION, LOCAL CHARGED-SECONDARY ENERGY
C                     DEPOSITION
C               3, NUCLEAR ATTENUATION, LOCAL CHARGED-SECONDARY ENERGY
C                     DEPOSITION, AND APPROX EXPONENTIAL DISTRIBUTION OF
C                     NEUTRON DOSE
C
C        IMAX = Number of shielding depth (max allowed=71)
C
C        IUNT = the shielding depth unit
C               1, Mils
C               2, g/cm2
C               3, mm
C
C        Zin = array(IMAX) of thickness in unit of IUNT
C
C        EMINS,EMAXS= the min and max energy of solar protons spectrum [MeV]
C        EMINP,EMAXP= the min and max energy of trapped protons spectrum [MeV]
C        NPTSP= number of spectrum points which divides proton spectra for integration.
C        EMINE,EMAXE= the min and max energy of trapped electrons spectrum [MeV]
C        NPTSE=number of spectrum points which divides electron spectrum for integration.
C
C        JSMAX= number of points in falling spectrum of solar protons
C        JPMAX= number of points in falling spectrum of trapped protons
C        JEMAX= number of points in falling spectrum of trapped electrons
C
C        EUNIT= CONVERSION FACTOR FROM /ENERGY TO /MEV,
C             E.G., EUNIT = 1000 IF FLUX IS /KEV.
C
C        DURATN= MISSION DURATION IN MULTIPLES OF UNIT TIME (s).
C
C        INCIDENT OMNIDIRECTIONAL FLUX IN /ENERGY/CM2/UNIT TIME
C             (SOLAR-FLARE FLUX IN /ENERGY/CM2).
C        ESin: Energy array(JSMAX) of solar proton spectrum
C        SFLUXin: Flux array(JSMAX) for solar protons( SOLAR-FLARE FLUX IN /ENERGY/CM2)
C
C        EPin: Energy array(JPMAX) of trapped proton spectrum
C        PFLUXin: Flux array(JPMAX) for trapped  protons (INCIDENT OMNIDIRECTIONAL FLUX IN /ENERGY/CM2/UNIT TIME)
C
C        EEin: Energy array(JEMAX) of trapped electron spectrum
C        EFLUXin: Flux array(JEMAX) for trapped  electrons (INCIDENT OMNIDIRECTIONAL FLUX IN /ENERGY/CM2/UNIT TIME)
C
C        OUTPUTS:
C        SolDose: Dose profile array (Imax,3) for solar protons
C        ProtDose: Dose profile array (Imax,3) for trapped protons
C        ElecDose: Dose profile array (Imax,3) for trapped electrons
C        BremDose: Dose profile array (Imax,3) for Brem
C        TotDose: Total dose profile array (Imax,3)
C
C     IMPLICIT DOUBLE PRECISION (A-H,O-Z)

      subroutine shieldose2(IDET,INUC,IMAX,IUNT,Zin,
     * EMINS,EMAXS,EMINP,EMAXP,NPTSP,EMINE,EMAXE,NPTSE,
     * JSMAX,JPMAX,JEMAX,EUNIT,DURATN,
     * ESin,SFLUXin,EPin,PFLUXin,EEin,EFLUXin,
     * SolDose,ProtDose,ElecDose,BremDose,TotDose)

      implicit none

      integer*4 MMAXPI,KMAXPI,NMAXPI,LMAXPI,IMIXI,MMAXEI,NMAXEI,LMAXSI
      integer*4 LMAXEI,LMAXTI,LMAXBI,IMAXI,NPTSI,JMAXI
      PARAMETER  (MMAXPI=133,KMAXPI=30,NMAXPI=49,LMAXPI=51,IMIXI=11,
     1   MMAXEI=81,NMAXEI=14,LMAXSI=33+1,LMAXEI=51,LMAXTI=37,LMAXBI=47,
     2   IMAXI=71,NPTSI=1001,JMAXI=301)
      integer*4 NPTSPI,NPTSEI
      PARAMETER  (NPTSPI=NPTSI,NPTSEI=NPTSI)
      real*8 ZCON,ZMCON
C     PARAMETER  (ZCON=0.001D0*2.540005D0*2.70D0,ZMCON=10.0D0/2.70D0)
      PARAMETER  (ZCON=0.0068580134999D0,ZMCON=3.7037037037033D0)
      CHARACTER  TAG*81,DET(IMIXI)*8,
     1   VERSION*4
      real*8  EP(MMAXPI),RP(MMAXPI),RPB(MMAXPI),RPC(MMAXPI),
     1   RPD(MMAXPI),TEPN(KMAXPI),FEPN(KMAXPI),FEPNB(KMAXPI),
     2   FEPNC(KMAXPI),FEPND(KMAXPI),TP(NMAXPI),ZRP(LMAXPI),
     3   DALP(NMAXPI,LMAXPI),DALPB(NMAXPI,LMAXPI),
     4   DALPC(NMAXPI,LMAXPI),DALPD(NMAXPI,LMAXPI),
     5   DRATP(NMAXPI,LMAXPI),DRATPB(NMAXPI,LMAXPI),
     6   DRATPC(NMAXPI,LMAXPI),DRATPD(NMAXPI,LMAXPI)
      real*8  EE(MMAXEI),RE(MMAXEI),REB(MMAXEI),REC(MMAXEI),
     1   RED(MMAXEI),YE(MMAXEI),YEB(MMAXEI),YEC(MMAXEI),YED(MMAXEI),
     2   TE(NMAXEI),AR(NMAXEI),ARB(NMAXEI),ARC(NMAXEI),ARD(NMAXEI),
     3   RS(NMAXEI),RSB(NMAXEI),RSC(NMAXEI),RSD(NMAXEI),BS(LMAXSI),
     4   ZRE(LMAXEI),ZS(LMAXTI),ZB(LMAXBI),DALE(NMAXEI,LMAXSI),
     5   DALEB(NMAXEI,LMAXSI),DALEC(NMAXEI,LMAXSI),DALED(NMAXEI,LMAXSI),
     6   DALB(NMAXEI,LMAXTI),DALBB(NMAXEI,LMAXTI),DALBC(NMAXEI,LMAXTI),
     7   DALBD(NMAXEI,LMAXTI),DRATE(NMAXEI,LMAXEI,2),
     8   DRATEB(NMAXEI,LMAXEI,2),DRATEC(NMAXEI,LMAXEI,2),
     9   DRATED(NMAXEI,LMAXEI,2),DRATB(NMAXEI,LMAXBI,2),
     X   DRATBB(NMAXEI,LMAXBI,2),DRATBC(NMAXEI,LMAXBI,2),
     1   DRATBD(NMAXEI,LMAXBI,2)
      real*8  ZM(IMAXI),Z(IMAXI),ZMM(IMAXI),ZL(IMAXI),TPL(NPTSPI),
     1   TPP(NPTSPI),TEL(NPTSEI),ENEWT(NPTSPI),TEE(NPTSEI),RINE(NPTSEI),
     2   RINS(NPTSEI),ARES(NPTSEI),YLDE(NPTSEI),DIN(LMAXPI),
     3   DINB(LMAXPI),DINC(LMAXPI),DIND(LMAXPI),DRIN(LMAXPI),
     4   GP(NPTSPI,IMAXI),GE(NPTSEI,IMAXI,2),GB(NPTSEI,IMAXI,2),
     5   EPS(JMAXI),S(JMAXI),SOL(NPTSPI),SPG(NPTSPI),SEG(NPTSEI),
     6   G(NPTSI),DOSOL(IMAXI,2),DOSP(IMAXI,2),DOSE(IMAXI,2,2),
     7   DOSB(IMAXI,2,2)
c
C     missing declaration
      real*8 ZMIN,RADCON,ENMU,EMINU,EMAXU,DEP,EMINUL,DELP
      integer*4 NBEGE,INATT,INEWT,IMIX
      integer*4 MMAXP,KMAXP,NMAXP,LMAXP,IMIXP
      integer*4 MMAXE,NMAXE,LMAXS,LMAXE,LMAXT,LMAXB,IMIXE
      integer*4 M,K,L,N,NLENE,I,J
      integer*4 NFSTSB,NLSTSB,NLENSB
      integer*4 NFSTPB,NLSTPB,NLENPB
      real*8 ANS,RINP,ANSR,BENMU,ZRIN,EMINEL,DEE,DELE
      integer*4 NE,NP,ISOL,NLENS
      integer*4 NFSTS,NLSTS,ITRP,NLENP,NFSTP,NLSTP,ILEC,NFSTE,NLSTE
      real*8 ZRINL,DELTAS,DELTAP,DELTAE,ENEUT,EAV
c
c     declaration added to cleanup the code and avoid memory fault
      real*8 dosSphIN(IMAXI),dosSpOut(IMAXI)
cccc INPUTS:
      INTEGER*4 IDET, INUC, IMAX, IUNT
      REAL*8 Zin(IMAXI)
      REAL*8 EMINS,EMAXS,EMINP,EMAXP,EMINE,EMAXE
      INTEGER*4 NPTSP,NPTSE
      INTEGER*4 JSMAX,JPMAX,JEMAX
      REAL*8 EUNIT,DURATN
      REAL*8 ESin(JMAXI),SFLUXin(JMAXI)
      REAL*8 EPin(JMAXI),PFLUXin(JMAXI)
      REAL*8 EEin(JMAXI),EFLUXin(JMAXI)
      REAL*8 SolDose(IMAXI,3), ProtDose(IMAXI,3)
      REAL*8 ElecDose(IMAXI,3), BremDose(IMAXI,3), TotDose(IMAXI,3)
ccccccEND OF INPUTS cccccccccccccccccccccccc

      COMMON /sd2pro/MMAXP,KMAXP,NMAXP,LMAXP,IMIXP
      COMMON /sd2proTab/EP,RP,TEPN,FEPN,TP,ZRP,
     &DALP,DRATP
      COMMON /sd2elbr/MMAXE,NMAXE,LMAXS,LMAXE,
     &LMAXT,LMAXB,IMIXE
      COMMON /sd2elbrTab/EE,RE,YE,TE,AR,RS,BS,ZRE
     &,ZS,ZB,DALE,DALB,DRATE,DRATB


      DATA  DET/'Aluminum','Graphite','Silicon','Air','Bone','CaF2',
     1   'GaAs','LiF','SiO2','Tissue','H2O'/
      DATA  ZMIN/1.0E-06/,RADCON/1.6021892E-08/,NBEGE/1/,ENMU/0.03/
      DATA  VERSION/'2.10'/
c
c     add init var to 0
      NLSTS = 0
      NLSTP = 0
      NLSTE = 0
      NFSTS = 0
      NFSTP = 0
      NFSTE = 0
c     end add var
c
C      CALL LOGO (VERSION)
c      PRINT 10
c   10 FORMAT (' Enter input filename: ')
c      READ 20,FILENM
c   20 FORMAT (A)
c      OPEN (UNIT=9,FILE=FILENM)
c      READ (9,20) PRTFIL
c      OPEN (UNIT=10,FILE=PRTFIL)
c      READ (9,20) ARRFIL
c      OPEN (UNIT=12,FILE=ARRFIL)
c      WRITE (10,30) VERSION
c      WRITE (12,30) VERSION
c   30 FORMAT (' OUTPUT FROM SHIELDOSE-2, VERSION ',A)
c      WRITE (10,32) FILENM
c      WRITE (12,32) FILENM
c   32 FORMAT (' Input filename: ',A)
c      WRITE (10,34) PRTFIL
c      WRITE (12,34) PRTFIL
c   34 FORMAT (' Print-out filename: ',A)
c      WRITE (10,36) ARRFIL
c      WRITE (12,36) ARRFIL
c   36 FORMAT (' Array output filename: ',A)
c      WRITE (10,370)
c  370 FORMAT (/'  IDET  INUC  IMAX  IUNT')
c      READ (9,*) IDET,INUC,IMAX,IUNT
c      WRITE (10,380) IDET,INUC,IMAX,IUNT
c  380 FORMAT (12I6)
c      WRITE (12,380) IDET,IMAX,INUC
      INATT=2
      IF (INUC.EQ.1) INATT=1
      INEWT=0
      IF (INUC.EQ.3) INEWT=1
!      PRINT *,' Reading database and preparing base arrays.............'
!      PRINT *,'    Protons.............................................'
!      OPEN (UNIT=11,FILE='PROTBAS2.DAT')
!      READ (11,20) TAG
!      READ (11,*) MMAXP,KMAXP,NMAXP,LMAXP,IMIX
!      READ (11,*) (EP(M),M=1,MMAXP)
!      READ (11,*) (RP(M),M=1,MMAXP)
!      READ (11,*) (TEPN(K),K=1,KMAXP)
!      READ (11,*) (FEPN(K),K=1,KMAXP)
!      READ (11,*) (TP(N),N=1,NMAXP)
!      READ (11,*) (ZRP(L),L=1,LMAXP)
!      DO 50 N=1,NMAXP
!      DO 38 I=1,2
!      READ (11,*) (DUM(L),L=1,LMAXP)
!      IF (I.NE.INATT) GO TO 38
!      DO 390 L=1,LMAXP
!  390 DALP(N,L)=DUM(L)
!      DALP(N,LMAXP)=(DALP(N,LMAXP-1)/DALP(N,LMAXP-2))*DALP(N,LMAXP-1)
!   38 CONTINUE
!      DO 40 I=1,IMIX
!      READ (11,*) (DUM(L),L=1,LMAXP)
!      IF (I.NE.IDET) GO TO 40
!      DO 39 L=1,LMAXP
!   39 DRATP(N,L)=DUM(L)
!   40 CONTINUE
!   50 CONTINUE
!      CLOSE (11)
      call protbas2(INATT,IDET,tag)
      IMIX=IMIXP

      DO 60 M=1,MMAXP
      EP(M)=LOG(EP(M))
   60 RP(M)=LOG(RP(M))
      DO 65 K=1,KMAXP
   65 TEPN(K)=LOG(TEPN(K))
      DO 70 N=1,NMAXP
   70 TP(N)=LOG(TP(N))
      CALL SCOF (MMAXP,EP,RP,RPB,RPC,RPD)
      CALL SCOF (KMAXP,TEPN,FEPN,FEPNB,FEPNC,FEPND)
      DO 75 L=1,LMAXP
      DO 72 N=1,NMAXP
   72 DALP(N,L)=LOG(DALP(N,L))
      CALL SCOF (NMAXP,TP,DALP(1,L),DALPB(1,L),DALPC(1,L),DALPD(1,L))
   75 CONTINUE
!      PRINT *,'    Electrons and bremsstrahlung........................'
!      OPEN (UNIT=11,FILE='ELBRBAS2.DAT')
!      READ (11,20) TAG
!      READ (11,*) MMAXE,NMAXE,LMAXS,LMAXE,LMAXT,LMAXB,IMIX
      call elbrbas2(IDET,tag)
      IMIX=IMIXE
      NLENE=NMAXE-NBEGE+1
!      READ (11,*) (EE(M),M=1,MMAXE)
!      READ (11,*) (RE(M),M=1,MMAXE)
!      READ (11,*) (YE(M),M=1,MMAXE)
!      READ (11,*) (TE(N),N=1,NMAXE)
!      READ (11,*) (AR(N),N=1,NMAXE)
!      READ (11,*) (RS(N),N=1,NMAXE)
!      READ (11,*) (BS(L),L=1,LMAXS)
!      BS(LMAXS+1)=2.0
!      READ (11,*) (ZRE(L),L=1,LMAXE)
!      READ (11,*) (ZS(L),L=1,LMAXT)
!      READ (11,*) (ZB(L),L=1,LMAXB)
!      DO 100 N=1,NMAXE
!      READ (11,*) (DALE(N,L),L=1,LMAXS)
!      DALE(N,LMAXS+1)=1.0E-07
!      READ (11,*) (DALB(N,L),L=1,LMAXT)
!      DO 90 I=1,IMIX
!      DO 80 M=1,2
!      READ (11,*) (DUM(L),L=1,LMAXE)
!      IF (I.NE.IDET) GO TO 77
!      DO 76 L=1,LMAXE
!   76 DRATE(N,L,M)=DUM(L)
!   77 READ (11,*) (DUM(L),L=1,LMAXB)
!      IF (I.NE.IDET) GO TO 80
!      DO 78 L=1,LMAXB
!   78 DRATB(N,L,M)=DUM(L)
!   80 CONTINUE
!   90 CONTINUE
!  100 CONTINUE
      LMAXS=LMAXS+1
!      CLOSE (11)
      DO 110 M=1,MMAXE
      EE(M)=LOG(EE(M))
      RE(M)=LOG(RE(M))
  110 YE(M)=LOG(YE(M))
      DO 120 N=1,NMAXE
      TE(N)=LOG(TE(N))
      AR(N)=LOG(AR(N))
  120 RS(N)=LOG(RS(N))
      DO 130 L=1,LMAXB
  130 ZB(L)=LOG(ZB(L))
      CALL SCOF (MMAXE,EE,RE,REB,REC,RED)
      CALL SCOF (MMAXE,EE,YE,YEB,YEC,YED)
      CALL SCOF (NMAXE,TE,AR,ARB,ARC,ARD)
      CALL SCOF (NMAXE,TE,RS,RSB,RSC,RSD)
      DO 150 L=1,LMAXS
      DO 140 N=NBEGE,NMAXE
  140 DALE(N,L)=LOG(DALE(N,L))
      CALL LCOF (NLENE,TE(NBEGE),DALE(NBEGE,L),DALEB(NBEGE,L),
     1   DALEC(NBEGE,L),DALED(NBEGE,L))
C     CALL SCOF (NLENE,TE(NBEGE),DALE(NBEGE,L),DALEB(NBEGE,L),
C    1   DALEC(NBEGE,L),DALED(NBEGE,L))
  150 CONTINUE
      DO 170 L=1,LMAXT
      ZS(L)=LOG(ZS(L))
      DO 160 N=NBEGE,NMAXE
  160 DALB(N,L)=LOG(DALB(N,L))
      CALL LCOF (NLENE,TE(NBEGE),DALB(NBEGE,L),DALBB(NBEGE,L),
     1   DALBC(NBEGE,L),DALBD(NBEGE,L))
C     CALL SCOF (NLENE,TE(NBEGE),DALB(NBEGE,L),DALBB(NBEGE,L),
C    1   DALBC(NBEGE,L),DALBD(NBEGE,L))
  170 CONTINUE
!      PRINT *,' Preparing base arrays for selected detector material...'
      DO 220 L=1,LMAXP
      CALL SCOF (NMAXP,TP,DRATP(1,L),DRATPB(1,L),DRATPC(1,L),
     1   DRATPD(1,L))
  220 CONTINUE
      DO 240 M=1,2
      DO 230 L=1,LMAXE
      CALL LCOF (NLENE,TE(NBEGE),DRATE(NBEGE,L,M),
     1   DRATEB(NBEGE,L,M),DRATEC(NBEGE,L,M),DRATED(NBEGE,L,M))
C     CALL SCOF (NLENE,TE(NBEGE),DRATE(NBEGE,L,M),
C    1   DRATEB(NBEGE,L,M),DRATEC(NBEGE,L,M),DRATED(NBEGE,L,M))
  230 CONTINUE
  240 CONTINUE
      DO 260 M=1,2
      DO 250 L=1,LMAXB
      CALL LCOF (NLENE,TE(NBEGE),DRATB(NBEGE,L,M),
     1   DRATBB(NBEGE,L,M),DRATBC(NBEGE,L,M),DRATBD(NBEGE,L,M))
C     CALL SCOF (NLENE,TE(NBEGE),DRATB(NBEGE,L,M),
C    1   DRATBB(NBEGE,L,M),DRATBC(NBEGE,L,M),DRATBD(NBEGE,L,M))
  250 CONTINUE
  260 CONTINUE
      GO TO (440,470,500), IUNT
  440 continue
c  440 WRITE (10,450)
c  450 FORMAT (/' SHIELD DEPTH (mils)')
c      READ (9,*) (ZM(I),I=1,IMAX)
c      WRITE (10,455) (ZM(I),I=1,IMAX)
c  455 FORMAT (1P6E12.5)
      do I = 1,IMAX
        ZM(I) = Zin(I)
      enddo
      DO 460 I=1,IMAX
      IF (ZM(I).LE.ZMIN/ZCON) ZM(I)=ZMIN/ZCON
      Z(I)=ZCON*ZM(I)
  460 ZMM(I)=Z(I)*ZMCON
      GO TO 530
  470 continue
c  470 WRITE (10,480)
c  480 FORMAT (/' SHIELD DEPTH (g/cm2)')
c      READ (9,*) (Z(I),I=1,IMAX)
c      WRITE (10,455) (Z(I),I=1,IMAX)
      DO I=1,IMAX
         Z(I) = Zin(I)
      ENDDO
      DO 490 I=1,IMAX
      IF (Z(I).LE.ZMIN) Z(I)=ZMIN
      ZM(I)=Z(I)/ZCON
  490 ZMM(I)=Z(I)*ZMCON
      GO TO 530
  500 continue
c  500 WRITE (10,510)
c  510 FORMAT (/' SHIELD DEPTH (mm)')
c      READ (9,*) (ZMM(I),I=1,IMAX)
c      WRITE (10,455) (ZMM(I),I=1,IMAX)
      DO I=1,IMAX
        ZMM(I) = Zin(I)
      ENDDO
      DO 520 I=1,IMAX
      IF (ZMM(I).LE.ZMIN*ZMCON) ZMM(I)=ZMIN*ZMCON
      Z(I)=ZMM(I)/ZMCON
  520 ZM(I)=Z(I)/ZCON
  530 DO 540 I=1,IMAX
  540 ZL(I)=LOG(Z(I))
c      WRITE (12,1435) (Z(I),I=1,IMAX)
c      WRITE (10,550)
c  550 FORMAT(/'     EMINS     EMAXS     EMINP     EMAXP NPTSP     EMINE
c     1    EMAXE NPTSE')
c      READ (9,*) EMINS,EMAXS,EMINP,EMAXP,NPTSP,EMINE,EMAXE,NPTSE
c      WRITE (10,560) EMINS,EMAXS,EMINP,EMAXP,NPTSP,EMINE,EMAXE,NPTSE
c  560 FORMAT (4F10.3,I6,2F10.3,I6)
      EMINU=MIN(EMINP,EMINS)
      EMAXU=MAX(EMAXP,EMAXS)
      DEP=LOG(EMAXU/EMINU)/FLOAT(NPTSP-1)
      EMINUL=LOG(EMINU)
      DELP=DEP/3.0
      CALL EINDEX (EMINU,DEP,NPTSP,EMINS,EMAXS,NFSTSB,NLSTSB,NLENSB)
      CALL EINDEX (EMINU,DEP,NPTSP,EMINP,EMAXP,NFSTPB,NLSTPB,NLENPB)
      DO 570 NP=1,NPTSP
      TPL(NP)=EMINUL+FLOAT(NP-1)*DEP
      TPP(NP)=EXP(TPL(NP))
  570 CONTINUE
c      WRITE (10,580) TPP(NFSTSB),TPP(NLSTSB),TPP(NFSTPB),TPP(NLSTPB),
c     1   NPTSP,EMINE,EMAXE,NPTSE
c  580 FORMAT (4F10.3,I6,2F10.3,I6,'  ADJUSTED VALUES')
c      WRITE (12,560) TPP(NFSTSB),TPP(NLSTSB),TPP(NFSTPB),TPP(NLSTPB),
c     1   NPTSP,EMINE,EMAXE,NPTSE
!      PRINT *,' Preparing mesh arrays to be integrated over spectra....'
!      PRINT *,'    Protons.............................................'
      DO 660 NP=1,NPTSP
      CALL BSPOL (TPL(NP),MMAXP,EP,RP,RPB,RPC,RPD,ANS)
      RINP=EXP(ANS)
      DO 610 L=1,LMAXP
      IF (TPL(NP).LT.TP(NMAXP)) GO TO 590
      ANS=DALP(NMAXP,L)
      ANSR=DRATP(NMAXP,L)
      GO TO 605
  590 IF (TPL(NP).GT.TP(1)) GO TO 600
      ANS=DALP(1,L)
      ANSR=DRATP(1,L)
      GO TO 605
  600 CALL BSPOL (TPL(NP),NMAXP,TP,DALP(1,L),DALPB(1,L),
     1   DALPC(1,L),DALPD(1,L),ANS)
      ANSR=1.0
      IF (IDET.EQ.1) GO TO 605
      CALL BSPOL (TPL(NP),NMAXP,TP,DRATP(1,L),DRATPB(1,L),
     1   DRATPC(1,L),DRATPD(1,L),ANSR)
  605 DIN(L)=ANS+LOG(ANSR)
  610 CONTINUE
      ENEWT(NP)=0.0
      BENMU=0.0
      IF (INATT.EQ.1) GO TO 620
      IF (TPL(NP).LE.TEPN(1)) GO TO 615
      CALL BSPOL (TPL(NP),KMAXP,TEPN,FEPN,FEPNB,FEPNC,FEPND,ANS)
      ENEWT(NP)=TPP(NP)*ANS
  615 BENMU=ENEWT(NP)*ENMU
  620 CALL SCOF (LMAXP,ZRP,DIN,DINB,DINC,DIND)
      DO 650 I=1,IMAX
      ZRIN=Z(I)/RINP
      IF (ZRIN.LT.ZRP(LMAXP)) GO TO 640
      GP(NP,I)=0.0
      GO TO 645
  640 CALL BSPOL (ZRIN,LMAXP,ZRP,DIN,DINB,DINC,DIND,ANS)
      ANS=EXP(ANS)
      GP(NP,I)=TPP(NP)*ANS/RINP
  645 IF (INEWT.EQ.1.AND.TPL(NP).GT.TEPN(1)) GP(NP,I)=GP(NP,I)+
     1   BENMU*EXP(-ENMU*Z(I))
  650 CONTINUE
  660 CONTINUE
!      PRINT *,'    Electrons and bremsstrahlung try...................'
      EMINEL=LOG(EMINE)
      DEE=(LOG(EMAXE)-EMINEL)/FLOAT(NPTSE-1)
      DELE=DEE/3.0
      DO 670 NE=1,NPTSE
      TEL(NE)=EMINEL+FLOAT(NE-1)*DEE
      TEE(NE)=EXP(TEL(NE))
      CALL BSPOL (TEL(NE),MMAXE,EE,RE,REB,REC,RED,ANS)
      RINE(NE)=EXP(ANS)
      CALL BSPOL (TEL(NE),NMAXE,TE,RS,RSB,RSC,RSD,ANS)
      RINS(NE)=RINE(NE)*EXP(ANS)
      CALL BSPOL (TEL(NE),NMAXE,TE,AR,ARB,ARC,ARD,ANS)
      ARES(NE)=EXP(ANS)
      CALL BSPOL (TEL(NE),MMAXE,EE,YE,YEB,YEC,YED,ANS)
  670 YLDE(NE)=EXP(ANS)
      DO 820 M=1,2
      DO 815 NE=1,NPTSE
      DO 700 L=1,LMAXS
      IF (TEL(NE).LT.TE(NMAXE)) GO TO 680
      DIN(L)=DALE(NMAXE,L)
      GO TO 700
  680 IF (TEL(NE).GT.TE(NBEGE)) GO TO 690
      DIN(L)=DALE(NBEGE,L)
      GO TO 700
  690 CALL BSPOL (TEL(NE),NLENE,TE(NBEGE),DALE(NBEGE,L),DALEB(NBEGE,L),
     1   DALEC(NBEGE,L),DALED(NBEGE,L),DIN(L))
  700 CONTINUE
      DO 715 L=1,LMAXE
      DRIN(L)=1.0
      IF (IDET.EQ.1.AND.M.EQ.1) GO TO 715
      IF (TEL(NE).LT.TE(NMAXE)) GO TO 710
      DRIN(L)=DRATE(NMAXE,L,M)
      GO TO 715
  710 IF (TEL(NE).GT.TE(NBEGE)) GO TO 712
      DRIN(L)=DRATE(NBEGE,L,M)
      GO TO 715
  712 CALL BSPOL (TEL(NE),NLENE,TE(NBEGE),DRATE(NBEGE,L,M),
     1   DRATEB(NBEGE,L,M),DRATEC(NBEGE,L,M),DRATED(NBEGE,L,M),DRIN(L))
      IF (DRIN(L).LT.0.0) DRIN(L)=0.0
  715 CONTINUE
C     CALL LCOF (LMAXS,BS,DIN,DINB,DINC,DIND)
      CALL SCOF (LMAXS,BS,DIN,DINB,DINC,DIND)
      DO 740 I=1,IMAX
      ZRIN=Z(I)/RINS(NE)
      IF (ZRIN.LT.BS(LMAXS)) GO TO 730
  720 GE(NE,I,M)=0.0
      GO TO 740
  730 CALL BSPOL (ZRIN,LMAXS,BS,DIN,DINB,DINC,DIND,ANS)
      ANS=EXP(ANS)
      GE(NE,I,M)=TEE(NE)*ANS*ARES(NE)/RINS(NE)
  740 CONTINUE
C     CALL LCOF (LMAXE,ZRE,DRIN,DINB,DINC,DIND)
      CALL SCOF (LMAXE,ZRE,DRIN,DINB,DINC,DIND)
      DO 745 I=1,IMAX
      ZRIN=Z(I)/RINE(NE)
      IF (ZRIN.LT.ZRE(LMAXE)) GO TO 742
      GE(NE,I,M)=GE(NE,I,M)*DRIN(LMAXE)
      GO TO 745
  742 CALL BSPOL (ZRIN,LMAXE,ZRE,DRIN,DINB,DINC,DIND,ANSR)
      IF (ANSR.LT.0.0) ANSR=0.0
      GE(NE,I,M)=GE(NE,I,M)*ANSR
  745 CONTINUE
      DO 780 L=1,LMAXT
      IF (TEL(NE).LT.TE(NMAXE)) GO TO 760
      DIN(L)=DALB(NMAXE,L)
      GO TO 780
  760 IF (TEL(NE).GT.TE(NBEGE)) GO TO 770
      DIN(L)=DALB(NBEGE,L)
      GO TO 780
  770 CALL BSPOL (TEL(NE),NLENE,TE(NBEGE),DALB(NBEGE,L),DALBB(NBEGE,L),
     1   DALBC(NBEGE,L),DALBD(NBEGE,L),DIN(L))
  780 CONTINUE
      DO 795 L=1,LMAXB
      DRIN(L)=1.0
      IF (IDET.EQ.1.AND.M.EQ.1) GO TO 795
      IF (TEL(NE).LT.TE(NMAXE)) GO TO 790
      DRIN(L)=DRATB(NMAXE,L,M)
      GO TO 795
  790 IF (TEL(NE).GT.TE(NBEGE)) GO TO 792
      DRIN(L)=DRATB(NBEGE,L,M)
      GO TO 795
  792 CALL BSPOL (TEL(NE),NLENE,TE(NBEGE),DRATB(NBEGE,L,M),
     1   DRATBB(NBEGE,L,M),DRATBC(NBEGE,L,M),DRATBD(NBEGE,L,M),DRIN(L))
      IF (DRIN(L).LT.0.0) DRIN(L)=0.0
  795 CONTINUE
      CALL LCOF (LMAXT,ZS,DIN,DINB,DINC,DIND)
C     CALL SCOF (LMAXT,ZS,DIN,DINB,DINC,DIND)
      DO 800 I=1,IMAX
      ZRINL=LOG(Z(I)/RINE(NE))
      CALL BSPOL (ZRINL,LMAXT,ZS,DIN,DINB,DINC,DIND,ANS)
      ANS=EXP(ANS)
      GB(NE,I,M)=TEE(NE)*ANS*YLDE(NE)/RINE(NE)
  800 CONTINUE
      CALL LCOF (LMAXB,ZB,DRIN,DINB,DINC,DIND)
C     CALL SCOF (LMAXB,ZB,DRIN,DINB,DINC,DIND)
      DO 812 I=1,IMAX
      IF (ZL(I).LT.ZB(LMAXB)) GO TO 810
      GB(NE,I,M)=GB(NE,I,M)*DRIN(LMAXB)
      GO TO 812
  810 CALL BSPOL (ZL(I),LMAXB,ZB,DRIN,DINB,DINC,DIND,ANSR)
      IF (ANSR.LT.0.0) ANSR=0.0
      GB(NE,I,M)=GB(NE,I,M)*ANSR
  812 CONTINUE
  815 CONTINUE
  820 CONTINUE
!      PRINT *,' Performing calculations for input spectra..............'
  830 continue
c  830 WRITE (10,840)
c  840 FORMAT (/)
c      WRITE (10,850)
c  850 FORMAT (' ')
c      READ (9,20,END=1440) TAG
c      PRINT 860, TAG
c  860 FORMAT (4X,A)
c      WRITE (10,20) TAG
c      WRITE (12,20) TAG
c      WRITE (10,870)
c  870 FORMAT (/' JSMAX JPMAX JEMAX       EUNIT      DURATN')
c      READ (9,*)  JSMAX,JPMAX,JEMAX,EUNIT,DURATN
c      WRITE (10,880) JSMAX,JPMAX,JEMAX,EUNIT,DURATN
c      WRITE (12,880) JSMAX,JPMAX,JEMAX,EUNIT,DURATN
c  880 FORMAT (3I6,1P2E12.5)
      IF (DURATN.LE.0.0) DURATN=1.0
      DELTAS=RADCON*DELP/4.0
      DELTAP=DURATN*RADCON*DELP/4.0
      DELTAE=DURATN*RADCON*DELE/4.0
      IF (EUNIT.LE.0.0) EUNIT=1.0
      ISOL=2
      IF (JSMAX.LT.3) GO TO 900
      ISOL=1
c      WRITE (10,885)
c  885 FORMAT (//' E(MeV)')
c      READ (9,*) (EPS(J),J=1,JSMAX)
      DO J=1,JSMAX
        EPS(J) = ESin(J)
      ENDDO
c      WRITE (10,905) (EPS(J),J=1,JSMAX)
c      WRITE (12,905) (EPS(J),J=1,JSMAX)
c      WRITE (10,890)
c  890 FORMAT (/' SOLAR PROTON SPECTRUM (/energy/cm2)')
c      READ (9,*) (S(J),J=1,JSMAX)
      DO J=1,JSMAX
        S(J) = SFLUXin(J)
      ENDDO
c      WRITE (10,905) (S(J),J=1,JSMAX)
c      WRITE (12,905) (S(J),J=1,JSMAX)
      NLENS=NLENSB
      NFSTS=NFSTSB
      NLSTS=NLSTSB
      CALL SPECTR (JSMAX,EPS,S,EUNIT,EMINU,DEP,NPTSP,NFSTS,NLSTS,NLENS,
     1   TPP,TPL,SOL)
c      WRITE (10,891) TPP(NFSTS),TPP(NLSTS),NLENS
c  891 FORMAT (/' SPECTRUM INTEGRATED FROM',1PE11.4,' TO',1PE11.4,
c     1   ' MeV, USING',I5,' POINTS')
      DO 892 NP=NFSTS,NLSTS
  892 G(NP)=SOL(NP)*ENEWT(NP)
      CALL INTEG (DELP,G(NFSTS),NLENS,ENEUT)
      DO 894 NP=NFSTS,NLSTS
  894 G(NP)=SOL(NP)*TPP(NP)
      CALL INTEG (DELP,G(NFSTS),NLENS,EAV)
      ENEUT=ENEUT/EAV
c      WRITE (10,896) ENEUT
c  896 FORMAT (/' ASSUMED FRACTION OF BEAM ENERGY INTO NEUTRON ENERGY =',
c     1   1PE12.5)
  900 ITRP=2
      IF (JPMAX.LT.3) GO TO 920
      ITRP=1
c      WRITE (10,885)
c      READ (9,*) (EPS(J),J=1,JPMAX)
      DO J=1,JPMAX
        EPS(J) = EPin(J)
      ENDDO
c      WRITE (10,905) (EPS(J),J=1,JPMAX)
c      WRITE (12,905) (EPS(J),J=1,JPMAX)
c  905 FORMAT (1P10E12.4)
c      WRITE (10,910)
c  910 FORMAT (/' TRAPPED PROTON SPECTRUM (/energy/cm2/time)')
c      READ (9,*) (S(J),J=1,JPMAX)
      DO J=1,JPMAX
        S(J) = PFLUXin(J)
      ENDDO
c      WRITE (10,905) (S(J),J=1,JPMAX)
c      WRITE (12,905) (S(J),J=1,JPMAX)
      NLENP=NLENPB
      NFSTP=NFSTPB
      NLSTP=NLSTPB
      CALL SPECTR (JPMAX,EPS,S,EUNIT,EMINU,DEP,NPTSP,NFSTP,NLSTP,NLENP,
     1   TPP,TPL,SPG)
c      WRITE (10,891) TPP(NFSTP),TPP(NLSTP),NLENP
      DO 912 NP=NFSTP,NLSTP
  912 G(NP)=SPG(NP)*ENEWT(NP)
      CALL INTEG (DELP,G(NFSTP),NLENP,ENEUT)
      DO 914 NP=NFSTP,NLSTP
  914 G(NP)=SPG(NP)*TPP(NP)
      CALL INTEG (DELP,G(NFSTP),NLENP,EAV)
      ENEUT=ENEUT/EAV
c      WRITE (10,896) ENEUT
  920 ILEC=2
      IF (JEMAX.LT.3) GO TO 940
      ILEC=1
c      WRITE (10,885)
c      READ (9,*) (EPS(J),J=1,JEMAX)
      DO J=1,JEMAX
        EPS(J) = EEin(J)
      ENDDO
c      WRITE (10,905) (EPS(J),J=1,JEMAX)
c      WRITE (12,905) (EPS(J),J=1,JEMAX)
c      WRITE (10,930)
c  930 FORMAT (/' ELECTRON SPECTRUM (/energy/cm2/time)')
c      READ (9,*) (S(J),J=1,JEMAX)
      DO J=1,JEMAX
        S(J) = EFLUXin(J)
      ENDDO
c      WRITE (10,905) (S(J),J=1,JEMAX)
c      WRITE (12,905) (S(J),J=1,JEMAX)
      NLENE=NPTSE
      NFSTE=1
      NLSTE=NPTSE
      CALL SPECTR (JEMAX,EPS,S,EUNIT,EMINE,DEE,NPTSE,NFSTE,NLSTE,NLENE,
     1   TEE,TEL,SEG)
c
c      WRITE (10,891) TEE(NFSTE),TEE(NLSTE),NLENE
  940 GO TO (980,950), ISOL
!  950 DO 960 NP=NFSTS,NLSTS
!  960 SOL(NP)=0.0
  950 continue
      DO 970 J=1,2
      DO 970 I=1,IMAX
  970 DOSOL(I,J)=0.0
      GO TO 1010
  980 DO 1000 I=1,IMAX
      DO 990 NP=NFSTS,NLSTS
  990 G(NP)=SOL(NP)*GP(NP,I)
      CALL INTEG (DELTAS,G(NFSTS),NLENS,DOSOL(I,1))
 1000 CONTINUE
      do  I=1,IMAX
        dosSphIN(I)=DOSOL(I,1)
      enddo
      CALL SPHERE (ZL,dosSphIN,IMAX,dosSpOut)
      do  I=1,IMAX
        DOSOL(I,2)=dosSpOut(I)
      enddo

 1010 GO TO (1050,1020), ITRP
c 1020 DO 1030 NP=NFSTP,NLSTP
c 1030 SPG(NP)=0.0
 1020 continue
      DO 1040 J=1,2
      DO 1040 I=1,IMAX
 1040 DOSP(I,J)=0.0
      GO TO 1080
 1050 DO 1070 I=1,IMAX
      DO 1060 NP=NFSTP,NLSTP
 1060 G(NP)=SPG(NP)*GP(NP,I)
      CALL INTEG (DELTAP,G(NFSTP),NLENP,DOSP(I,1))
 1070 CONTINUE
      do  I=1,IMAX
        dosSphIN(I)=DOSP(I,1)
      enddo
      CALL SPHERE (ZL,dosSphIN,IMAX,dosSpOut)
      do  I=1,IMAX
        DOSP(I,2)=dosSpOut(I)
      enddo

 1080 GO TO (1110,1090), ILEC
 1090 DO 1100 J=1,2
      DO 1100 M=1,2
      DO 1100 I=1,IMAX
      DOSE(I,M,J)=0.0
 1100 DOSB(I,M,J)=0.0
      GO TO 1160
 1110 DO 1150 M=1,2
      DO 1130 I=1,IMAX
      DO 1120 NE=NFSTE,NLSTE
      G(NE)=SEG(NE)*GE(NE,I,M)
 1120 SPG(NE)=SEG(NE)*GB(NE,I,M)
      CALL INTEG (DELTAE,G(NFSTE),NLENE,DOSE(I,M,1))
      CALL INTEG (DELTAE,SPG(NFSTE),NLENE,DOSB(I,M,1))
 1130 CONTINUE
      GO TO (1140,1150), M
 1140 continue
      do  I=1,IMAX
        dosSphIN(I)=DOSE(I,M,1)
      enddo
      CALL SPHERE (ZL,dosSphIN,IMAX,dosSpOut)
      do  I=1,IMAX
        DOSE(I,M,2)=dosSpOut(I)
      enddo

      do  I=1,IMAX
        dosSphIN(I)=DOSB(I,M,1)
      enddo
      CALL SPHERE (ZL,dosSphIN,IMAX,dosSpOut)
      do  I=1,IMAX
        DOSB(I,M,2)=dosSpOut(I)
      enddo
 1150 CONTINUE
 1160 continue
ccccccccccccccccccccc my code to store outputs
c K=1, J=1,M=1, DOSE IN SEMI-INFINITE ALUMINUM MEDIUM
c K=2, J=1,M=2, DOSE AT TRANSMISSION SURFACE OF FINITE ALUMINUM SLAB SHIELDS
c K=3, J=2,M=1, 1/2 DOSE AT CENTER OF ALUMINUM SPHERES
c         DOSOL(I,J), DOSP(I,J), DOSE(I,J,M), DOSB(I,J,M)
!      write(6,*)'Format output ...'
      K=1
      J=1
      M=1
      DO I=1,IMAX
         ProtDose(I,K) = DOSP(I,J)
         SolDose(I,K) = DOSOL(I,J)
         ElecDose(I,K) = DOSE(I,M,J)
         BremDose(I,K) = DOSB(I,M,J)
         TotDose(I,K)=DOSP(I,J)+DOSOL(I,J)+DOSE(I,M,J)+DOSB(I,M,J)
      ENDDO
      K=2
      J=1
      M=2
      DO I=1,IMAX
         ProtDose(I,K) = DOSP(I,J)
         SolDose(I,K) = DOSOL(I,J)
         ElecDose(I,K) = DOSE(I,M,J)
         BremDose(I,K) = DOSB(I,M,J)
         TotDose(I,K)=DOSP(I,J)+DOSOL(I,J)+DOSE(I,M,J)+DOSB(I,M,J)
      ENDDO
      K=3
      J=2
      M=1
      DO I=1,IMAX
         ProtDose(I,K) = DOSP(I,J)
         SolDose(I,K) = DOSOL(I,J);
         ElecDose(I,K) = DOSE(I,M,J)
         BremDose(I,K) = DOSB(I,M,J)
         TotDose(I,K)=DOSP(I,J)+DOSOL(I,J)+DOSE(I,M,J)+DOSB(I,M,J)
      ENDDO

c 1160 return
ccccccccccccccccccccc all the rest of this code is just write statements

c 1160 J=1
c      DO 1340 M=2,1,-1
c      GO TO (1190,1170), M
c 1170 WRITE (10,1180)
c 1180 FORMAT(//' DOSE AT TRANSMISSION SURFACE OF FINITE ALUMINUM SLAB SH
c     1IELDS')
c      GO TO 1210
c 1190 WRITE (10,1200)
c 1200 FORMAT(//' DOSE IN SEMI-INFINITE ALUMINUM MEDIUM')
c 1210 WRITE (10,1230) DET(IDET)
c 1230 FORMAT (/' rads ',A)
c      IF (INATT.EQ.1) WRITE (10,1240)
c 1240 FORMAT (/' Proton results without nuclear attenuation')
c      IF (INATT.EQ.2) WRITE (10,1250)
c 1250 FORMAT (/' Proton results with approximate treatment of nuclear at
c     1tenuation')
c      IF (INATT.EQ.2.AND.INEWT.EQ.0) WRITE (10,1260)
c 1260 FORMAT ( '    neglecting transport of energy by neutrons')
c      IF (INATT.EQ.2.AND.INEWT.EQ.1) WRITE (10,1270)
c 1270 FORMAT ( '    and crude exponential transport of energy by neutron
c     1s')
c      WRITE (10,1310)
c 1310 FORMAT(/'    Z(mils)      Z(mm)   Z(g/cm2)   ELECTRON    BREMS
c     1  EL+BR     TRP PROT   SOL PROT  EL+BR+TRP    TOTAL')
c      WRITE (10,850)
c      DO 1330 I=1,IMAX
c      DOSEB=DOSE(I,M,J)+DOSB(I,M,J)
c      DOSEBP=DOSEB+DOSP(I,J)
c      DOST=DOSEBP+DOSOL(I,J)
c      WRITE (10,1320) ZM(I),ZMM(I),Z(I),DOSE(I,M,J),DOSB(I,M,J),DOSEB,
c     1   DOSP(I,J),DOSOL(I,J),DOSEBP,DOST
c 1320 FORMAT (1P10E11.3)
c      IF (FLOAT(I/10).EQ.0.1*FLOAT(I)) WRITE (10,850)
c 1330 CONTINUE
c 1340 CONTINUE
c      J=2
c      M=1
c      WRITE (10,1350)
c 1350 FORMAT (//' 1/2 DOSE AT CENTER OF ALUMINUM SPHERES')
c      WRITE (10,1230) DET(IDET)
c      IF (INATT.EQ.1) WRITE (10,1240)
c      IF (INATT.EQ.2) WRITE (10,1250)
c      IF (INATT.EQ.2.AND.INEWT.EQ.0) WRITE (10,1260)
c      IF (INATT.EQ.2.AND.INEWT.EQ.1) WRITE (10,1270)
c      WRITE (10,1310)
c      WRITE (10,850)
c      DO 1410 I=1,IMAX
c      DOSEB=DOSE(I,M,J)+DOSB(I,M,J)
c      DOSEBP=DOSEB+DOSP(I,J)
c      DOST=DOSEBP+DOSOL(I,J)
c      WRITE (10,1320) ZM(I),ZMM(I),Z(I),DOSE(I,M,J),DOSB(I,M,J),DOSEB,
c     1   DOSP(I,J),DOSOL(I,J),DOSEBP,DOST
c      IF (FLOAT(I/10).EQ.0.1*FLOAT(I)) WRITE (10,850)
c 1410 CONTINUE
c      DO 1437 J=1,2
c      WRITE (12,1435) (DOSOL(I,J),I=1,IMAX)
c      WRITE (12,1435) (DOSP(I,J),I=1,IMAX)
c 1435 FORMAT (1P10E10.3)
c 1437 CONTINUE
c      DO 1438 M=2,1,-1
c      WRITE (12,1435) (DOSE(I,M,1),I=1,IMAX)
c      WRITE (12,1435) (DOSB(I,M,1),I=1,IMAX)
c 1438 CONTINUE
c      WRITE (12,1435) (DOSE(I,1,2),I=1,IMAX)
c      WRITE (12,1435) (DOSB(I,1,2),I=1,IMAX)
c      GO TO 830
c 1440 PRINT 32, FILENM
c      PRINT 34, PRTFIL
c      PRINT 36, ARRFIL
cC      print 1500,CHAR(27)
cC 1500 format (' ',A1,'[0m')
c      STOP
      END

C     SUBROUTINE EINDEX (EMINB,DE,NPTS,EMIN,EMAX,NFST,NLST,NLEN), 28 APR 94.
      SUBROUTINE EINDEX (EMINB,DE,NPTS,EMIN,EMAX,NFST,NLST,NLEN)
      implicit none
C     IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      integer*4 NFST,NLST,NLEN,NPTS
      real*8 EMINB,EMIN,EMAX,DE

      NFST=LOG(EMIN/EMINB)/DE+0.5
      NFST=NFST+1
      IF (NFST.LT.1) NFST=1
      NLST=LOG(EMAX/EMINB)/DE+0.5
      NLST=NLST+1
      IF (NLST.GT.NPTS) NLST=NPTS
      NLEN=NLST-NFST+1
      RETURN
      END
C     SUBROUTINE SPECTR (JMAX,EPS,S,EUNIT,EMINB,DEL,NPTS,NFST,NLST,NLEN,
C    1   T,TL,SP), 28 APR 94.
      SUBROUTINE SPECTR (JMAX,EPS,S,EUNIT,EMINB,DEL,NPTS,NFST,NLST,NLEN,
     1   T,TL,SP)
      implicit none
c     IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      integer*4 JMAXI,NPTSI
      PARAMETER  (JMAXI=301,NPTSI=1001)
      integer*4 JMAX,NPTS,NFST,NLST,NLEN,N,J
      real*8  EPS(JMAXI),S(JMAXI),T(NPTSI),TL(NPTSI),SP(NPTSI),
     &   BCOF(JMAXI),CCOF(JMAXI),
     1   DCOF(JMAXI),G(NPTSI)
      real*8 EUNIT,EMINB,P,ARG
      real*8 EMC2,ARGLIM,DELTA,DEL,ALPHA,BETA,ANS,SIN,EBAR

C           ARGLIM = 700.0 (DOUBLE PRECISION), 85.0 (SINGLE PRECISION)
      DATA  EMC2/938.27231/,ARGLIM/85.0/
      DELTA=DEL/3.0
      IF (EPS(1).GT.0.0) GO TO 20
      ALPHA=S(1)
      BETA=S(2)
      IF (BETA.LE.0.0) BETA=1.0
      BETA=BETA/ALPHA
      DO 10 N=NFST,NLST
      SP(N)=0.0
      G(N)=0.0
      IF (S(3).LE.0.0) GO TO 6
      P=SQRT(T(N)*(T(N)+2.0*EMC2))
      ARG=P/ALPHA
      IF (ARG.GT.ARGLIM) GO TO 10
      SP(N)=T(N)*BETA*((T(N)+EMC2)/P)*EXP(-ARG)
      GO TO 8
    6 ARG=T(N)/ALPHA
      IF (ARG.GT.ARGLIM) GO TO 10
      SP(N)=T(N)*BETA*EXP(-ARG)
    8 G(N)=T(N)*SP(N)
   10 CONTINUE
      GO TO 50
   20 CALL EINDEX (EMINB,DEL,NPTS,EPS(1),EPS(JMAX),NFST,NLST,NLEN)
      DO 30 J=1,JMAX
      EPS(J)=LOG(EPS(J))
   30 S(J)=LOG(EUNIT*S(J))
      CALL SCOF (JMAX,EPS,S,BCOF,CCOF,DCOF)
      DO 40 N=NFST,NLST
      CALL BSPOL (TL(N),JMAX,EPS,S,BCOF,CCOF,DCOF,ANS)
      SP(N)=T(N)*EXP(ANS)
   40 G(N)=T(N)*SP(N)
   50 CALL INTEG (DELTA,SP(NFST),NLEN,SIN)
      CALL INTEG (DELTA,G(NFST),NLEN,EBAR)
      EBAR=EBAR/SIN
c      WRITE (10,60)
c   60 FORMAT (/'    INT SPEC    EAV(MeV)')
c      WRITE (10,70) SIN,EBAR
c   70 FORMAT (1PE12.4,0PF12.5)
      RETURN
      END
C     SUBROUTINE SPHERE (ZL,DOSE,IMAX,DOSPH), 26 JAN 93.
      SUBROUTINE SPHERE (ZL,DOSE,IMAX,DOSPH)
      implicit none
C     IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      integer*4 IMAXI,IMAX,I,IMIX,IMIX1
      PARAMETER  (IMAXI=71)
      real*8  ZL(IMAX),DOSE(IMAXI),DOSPH(IMAXI),DOSL(IMAXI),BCOF(IMAXI),
     1   CCOF(IMAXI),DCOF(IMAXI)
      DO 10 I=1,IMAX
      IF (DOSE(I).LE.0.0) GO TO 20
   10 DOSL(I)=LOG(DOSE(I))
      I=IMAX+1
   20 IMIX=I-1
      IF (IMIX.LT.3) GO TO 40
      CALL SCOF (IMIX,ZL,DOSL,BCOF,CCOF,DCOF)
      BCOF(IMIX)=BCOF(IMIX-1)+(2.0*CCOF(IMIX-1)+3.0*DCOF(IMIX-1)*
     1   (ZL(IMIX)-ZL(IMIX-1)))*(ZL(IMIX)-ZL(IMIX-1))
      DO 30 I=1,IMIX
   30 DOSPH(I)=DOSE(I)*(1.0-BCOF(I))
   40 IMIX1=IMIX+1
      IF (IMIX1.GT.IMAX) RETURN
      DO 50 I=IMIX1,IMAX
   50 DOSPH(I)=0.0
      RETURN
      END
      SUBROUTINE SCOF(N,X,Y,B,C,D)
      implicit none
C        REINSCH ALGORITHM, VIA MJB, 22 FEB 83
C        Y(S)=((D(J)*(X-X(J))+C(J))*(X-X(J))+B(J))*(X-X(J))+Y(J)
C             FOR X BETWEEN X(J) AND X(J+1)
C     IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      !DIMENSION X(1),Y(1),B(1),C(1),D(1)
      integer*4 N,N1,J,JR
c      real*8 X(N),Y(N),B(N),C(N),D(N)
      real*8 X,Y,B,C,D
      DIMENSION X(1),Y(1),B(1),C(1),D(1)
      real*8 S,R
      N1=N-1
      S=0.0
      DO 10 J=1,N1
      D(J)=X(J+1)-X(J)
      R=(Y(J+1)-Y(J))/D(J)
      C(J)=R-S
   10 S=R
      S=0.0
      R=0.0
      C(1)=0.0
      C(N)=0.0
      DO 20 J=2,N1
      C(J)=C(J)+R*C(J-1)
      B(J)=(X(J-1)-X(J+1))*2.0-R*S
      S=D(J)
   20 R=S/B(J)
      DO 30 JR=N1,2,-1
   30 C(JR)=(D(JR)*C(JR+1)-C(JR))/B(JR)
      DO 40 J=1,N1
      S=D(J)
      R=C(J+1)-C(J)
      D(J)=R/S
      C(J)=3.0*C(J)
   40 B(J)=(Y(J+1)-Y(J))/S-(C(J)+R)*S
      RETURN
      END
      SUBROUTINE BSPOL(S,N,X,Y,B,C,D,T)
      implicit none
C        BINARY SEARCH, X ASCENDING OR DESCENDING
C     IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      !DIMENSION X(1),Y(1),B(1),C(1),D(1)
      integer*4 N,IDIR,MLB,MUB,IDIR1,ML,MU,MAV
c      real*8 X(N),Y(N),B(N),C(N),D(N),T,S,Q
      real*8 X,Y,B,C,D,T,S,Q
      DIMENSION X(1),Y(1),B(1),C(1),D(1)

      IF (X(1).GT.X(N)) GO TO 10
      IDIR=0
      MLB=0
      MUB=N
      GO TO 20
   10 IDIR=1
      MLB=N
      MUB=0
   20 IDIR1=IDIR-1
      IF (S.GE.X(MUB+IDIR)) GO TO 60
      IF (S.LE.X(MLB-IDIR1)) GO TO 70
      ML=MLB
      MU=MUB
      GO TO 40
   30 IF (IABS(MU-ML).LE.1) GO TO 80
   40 MAV=(ML+MU)/2
      IF (S.LT.X(MAV)) GO TO 50
      ML=MAV
      GO TO 30
   50 MU=MAV
      GO TO 30
   60 MU=MUB+IDIR+IDIR1
      GO TO 90
   70 MU=MLB-IDIR-IDIR1
      GO TO 90
   80 MU=MU+IDIR1
   90 Q=S-X(MU)
      T=((D(MU)*Q+C(MU))*Q+B(MU))*Q+Y(MU)
      RETURN
      END
      SUBROUTINE LCOF (NMAX,X,F,B,C,D)
      implicit none
C        26 JAN 93.  SIMPLE LINEAR INTERPOLATION
C     IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      !DIMENSION  X(1), F(1), B(1), C(1), D(1)
      integer*4 NMAX,N
c      REAL*8  X(NMAX), F(NMAX), B(NMAX), C(NMAX), D(NMAX)
      REAL*8  X, F, B, C, D
      DIMENSION  X(1), F(1), B(1), C(1), D(1)

      DO 10 N=1,NMAX-1
      B(N)=(F(N+1)-F(N))/(X(N+1)-X(N))
      C(N)=0.0
      D(N)=0.0
   10 CONTINUE
      RETURN
      END
      SUBROUTINE INTEG (DELTA,G,N,RESULT)
      implicit none
C          INCLUDES N=1
C     IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      integer*4 N,NL1,NL2,K
      real*8 DELTA,result,SIGMA,SUM4,SUM2,SIG6
      real*8 G(*)
c      real*8 G
c      dimension G(1)

      NL1=N-1
      NL2=N-2
      IF (REAL (N) -2.0*REAL (N/2)) 100,100,10
   10  IF (N-1) 15,15,20
   15 SIGMA=0.0
      GO TO 70
   20 IF(N-3) 30,30,40
   30 SIGMA=G(1)+4.0*G(2)+G(3)
      GO TO 70
   40 SUM4=0.0
      DO 50 K=2,NL1,2
   50 SUM4=SUM4+G(K)
      SUM2=0.0
      DO 60 K=3,NL2,2
   60 SUM2=SUM2+G(K)
      SIGMA=G(1)+4.0*SUM4+2.0*SUM2+G(N)
   70 RESULT=DELTA*SIGMA
      RETURN
  100 IF(N-2)110,110,120
  110 SIGMA=1.5*(G(1)+G(2))
      GO TO 70
  120 IF(N-4)130,130,140
  130 SIGMA=1.125*(G(1)+3.0*G(2)+3.0*G(3)+G(4))
      GO TO 70
  140 IF(N-6)150,150,160
  150 SIGMA=G(1)+3.875*G(2)+2.625*G(3)+2.625*G(4)+3.875*G(5)+G(6)
      GO TO 70
  160 IF (N-8)170,170,180
  170 SIGMA=G(1)+3.875*G(2)+2.625*G(3)+2.625*G(4)+3.875*G(5)+2.0*G(6)
     1   +4.0*G(7)+G(8)
      GO TO 70
  180 SIG6=G(1)+3.875*G(2)+2.625*G(3)+2.625*G(4)+3.875*G(5)+G(6)
      SUM4=0.0
      DO 190 K=7,NL1,2
  190 SUM4=SUM4+G(K)
      SUM2=0.0
      DO 200 K=8,NL2,2
  200 SUM2=SUM2+G(K)
      SIGMA=SIG6+G(6)+4.0*SUM4+2.0*SUM2+G(N)
      GO TO 70
      END
