/*
 * KpiCard.java
 * Created on October 24, 2005
 * @author  siga0739-Aline Corrêa do Vale
 *
 */
package kpi.swing.analisys;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.Font;
import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.ResourceBundle;
import javax.swing.BorderFactory;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.SwingConstants;
import javax.swing.plaf.IconUIResource;
import kpi.beans.JBIColorStatusPanel;
import kpi.beans.JBIHyperlinkLabel;
import kpi.core.KpiStaticReferences;
import kpi.swing.framework.KpiListaPlanos;

public class KpiIndicadorCard extends javax.swing.JInternalFrame implements KpiCard {

    kpi.xml.BIXMLRecord record = null;
    java.util.Vector listData = new java.util.Vector();
    String id = new String(),
            entId = new String(),
            entity = new String();
    int order = -1;
    private kpi.core.KpiFormController formController = kpi.core.KpiStaticReferences.getKpiFormController();

    @Override
    public java.awt.Point getCardPosition() {
        java.awt.Point p = new java.awt.Point(record.getInt("CARDX"), record.getInt("CARDY"));
        return p;
    }

    @Override
    public void setOrder(int o) {
        order = o;
    }

    @Override
    public int getOrder() {
        return order;
    }

    @Override
    public String getNome() {
        return lblTitle.getText();
    }

    @Override
    public String getId() {
        return id;
    }

    /**
     * Creates new form KpiCardFrame
     */
    public KpiIndicadorCard(kpi.xml.BIXMLRecord recordAux) {
        this.record = recordAux;
        this.putClientProperty("JInternalFrame.isPalette", Boolean.TRUE);
        initComponents();
        slider.setEnabled(false);

        id = String.valueOf(record.getString("ID"));
        order = record.getInt("ORDEM");
        entity = String.valueOf(record.getString("ENTITY"));
        entId = String.valueOf(record.getString("ENTID"));

        //Validação de segurança
        if (kpi.core.KpiStaticReferences.getKpiMainPanel().jMnuIndicador.isVisible()) {
            lblTitle.setFoco(true);
        } else {
            lblTitle.setFoco(false);
        }

        lblTitle.setSize(new Dimension(70, 16));
        lblTitle.setType(record.getString("ENTITY"));
        lblTitle.setID(record.getString("ENTID"));
        lblTitle.setTitle(record.getString("NOME").trim());
        lblTitle.setAlignmentY(CENTER_ALIGNMENT);
        lblTitle.setText(record.getString("NOME").trim());
        lblTitle.setToolTipText(record.getString("NOME").trim());
        lblTitle.setIcon(new IconUIResource(kpi.core.KpiStaticReferences.getKpiMainPanel().getImageResources().getImage(record.getInt("TENDENCIA"))));
        lblDepto.setText(record.getString("NOMESCOREC").trim());
        lblDepto.setToolTipText(record.getString("NOMESCOREC").trim());
        if (record.getString("TIPOIND").trim().equals("T")) {
            setTitle(java.util.ResourceBundle.getBundle("international", kpi.core.KpiStaticReferences.getKpiDefaultLocale()).getString("KpiIndicadorCard_00001"));
            lblAnterior.setVisible(false);
            java.awt.Color corTendencia = new java.awt.Color(190, 230, 243);

            lblAtual.setBackground(corTendencia);
            lblTitle.setBackground(corTendencia);
            pnlTitle.setBackground(corTendencia);
            pnlValue.setBackground(corTendencia);
            pRight.setBackground(corTendencia);
            pLeft.setBackground(corTendencia);
            pnlDireito.setBackground(corTendencia);
            pnlEsquerdo.setBackground(corTendencia);
            pnlValores.setBackground(corTendencia);
            pnlTop.setBackground(corTendencia);
            pnlBottom.setBackground(corTendencia);
            pnlL.setBackground(corTendencia);
            pnlR.setBackground(corTendencia);
            pnlEscala.setBackground(corTendencia);
            lblValorPrevio.setBackground(corTendencia);
            pnlPrevistoAtual.setBackground(corTendencia);
            pnlIndText.setBackground(corTendencia);
        } else {
            setTitle(java.util.ResourceBundle.getBundle("international", kpi.core.KpiStaticReferences.getKpiDefaultLocale()).getString("KpiIndicadorCard_00002"));
            lblAnterior.setVisible(true);
        }

        //Se for Descendente inverte a ordem das cores
        if (record.getBoolean("ASCEND")) {
            slider.setAscend(true);
        } else {
            slider.setAscend(false);
        }
        slider.setRed(record.getInt("VERMELHO"));//ALVO1 é Verde
        slider.setGreen(record.getInt("VERDE")); //ALVO2 é Vermelho
        slider.setYellow(record.getInt("AMARELO"));  //Amarelo é o intervalo

        int posicao = record.getInt("PERCENTUAL");
        if (record.getBoolean("ASCEND")) {
            slider.setPosition(posicao);
        } else {
            slider.setPosition(100 - posicao);
        }

        java.text.NumberFormat nf = java.text.NumberFormat.getInstance();
        nf.setMaximumFractionDigits(record.getInt("DECIMAIS"));
        nf.setMinimumFractionDigits(record.getInt("DECIMAIS"));

        String cAnterior = nf.format(record.getDouble("ANTERIOR")) + " " + record.getString("UNIDADE");
        lblAnterior.setText(lblAnterior.getText().trim() + " " + cAnterior);

        String cDiferenca = nf.format(record.getDouble("DIF_REAL_META"));
        String cMeta = nf.format(record.getDouble("META"));
        lblMeta.setText(java.util.ResourceBundle.getBundle("international", kpi.core.KpiStaticReferences.getKpiDefaultLocale()).getString("KpiIndicadorCard_00005").concat(" " + cMeta));

        //Tool Tip da % atingida.
        int posAtualInd;
        posAtualInd = posicao * 2;
        slider.setToolTip(posAtualInd + "%");

        String cAtual = nf.format(record.getDouble("ATUAL")) + " " + record.getString("UNIDADE");
        lblAtual.setText(lblAtual.getText().trim() + " " + cAtual);

        if (record.contains("PREVIA")) {
            String cValorPrevio = nf.format(record.getDouble("PREVIA")) + " " + record.getString("UNIDADE");
            lblValorPrevio.setText(lblValorPrevio.getText().trim() + " " + cValorPrevio);
        } else {
            lblValorPrevio.setVisible(false);
        }
        lblInicial.setText(record.getString("INICIAL") + "%");
        lblFinal.setText(record.getString("FINAL") + "%");

        kpi.beans.JBIHyperlinkLabel label = null;
    }

    @Override
    public kpi.xml.BIXMLRecord getRecordData() {
        kpi.xml.BIXMLRecord recordAux = new kpi.xml.BIXMLRecord("CARD");
        recordAux.set("ID", id);
        recordAux.set("ENTITY", entity);
        recordAux.set("ENTID", entId);
        return recordAux;
    }

    /** This method is called from within the constructor to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
    private void initComponents() {//GEN-BEGIN:initComponents

        jPanel1 = new JPanel();
        pnlTitle = new JPanel();
        pnlIndText = new JPanel();
        lblDepto = new JLabel();
        lblTitle = new JBIHyperlinkLabel();
        pnlPrevistoAtual = new JPanel();
        lblMeta = new JLabel();
        jPanel2 = new JPanel();
        pnlSlider = new JPanel();
        slider = new JBIColorStatusPanel();
        pLeft = new JPanel();
        pRight = new JPanel();
        pnlValue = new JPanel();
        pnlValores = new JPanel();
        lblInicial = new JLabel();
        lblFinal = new JLabel();
        lblFinal1 = new JLabel();
        pnlDireito = new JPanel();
        pnlEsquerdo = new JPanel();
        pnlEscala = new JPanel();
        pnlR = new JPanel();
        btnGrafico = new JButton();
        btnIndicador = new JButton();
        pnlBottom = new JPanel();
        pnlL = new JPanel();
        pnlTop = new JPanel();
        pnlCenter = new JPanel();
        lblAnterior = new JLabel();
        lblValorPrevio = new JLabel();
        lblAtual = new JLabel();

        setClosable(true);
        setToolTipText("");
        setFrameIcon(new ImageIcon(getClass().getResource("/kpi/imagens/ic_indicador.gif"))); // NOI18N
        setPreferredSize(new Dimension(236, 225));

        jPanel1.setOpaque(false);
        jPanel1.setPreferredSize(new Dimension(140, 120));
        jPanel1.setLayout(new BorderLayout());

        pnlTitle.setPreferredSize(new Dimension(140, 40));
        pnlTitle.setLayout(new BorderLayout());

        pnlIndText.setAutoscrolls(true);
        pnlIndText.setLayout(new GridLayout());

        lblDepto.setHorizontalAlignment(SwingConstants.LEFT);
        lblDepto.setIcon(new ImageIcon(getClass().getResource("/kpi/imagens/ic_scorecard.gif"))); // NOI18N
        lblDepto.setText("TESTE");
        pnlIndText.add(lblDepto);
        pnlIndText.add(lblTitle);

        pnlTitle.add(pnlIndText, BorderLayout.NORTH);

        pnlPrevistoAtual.setLayout(new BorderLayout());

        lblMeta.setBackground(new Color(204, 204, 204));
        lblMeta.setFont(new Font("Tahoma", 1, 11));
        lblMeta.setHorizontalAlignment(SwingConstants.CENTER);
        lblMeta.setPreferredSize(new Dimension(180, 14));
        pnlPrevistoAtual.add(lblMeta, BorderLayout.CENTER);

        pnlTitle.add(pnlPrevistoAtual, BorderLayout.SOUTH);

        jPanel1.add(pnlTitle, BorderLayout.NORTH);

        jPanel2.setPreferredSize(new Dimension(140, 40));
        jPanel2.setLayout(new BorderLayout());

        pnlSlider.setPreferredSize(new Dimension(180, 20));
        pnlSlider.setLayout(new BorderLayout());

        slider.setBorder(BorderFactory.createEmptyBorder(1, 1, 1, 1));
        slider.setPreferredSize(new Dimension(200, 35));
        pnlSlider.add(slider, BorderLayout.CENTER);

        jPanel2.add(pnlSlider, BorderLayout.CENTER);

        pLeft.setPreferredSize(new Dimension(5, 5));
        jPanel2.add(pLeft, BorderLayout.WEST);

        pRight.setPreferredSize(new Dimension(5, 5));
        jPanel2.add(pRight, BorderLayout.EAST);

        jPanel1.add(jPanel2, BorderLayout.CENTER);

        pnlValue.setOpaque(false);
        pnlValue.setPreferredSize(new Dimension(140, 25));
        pnlValue.setRequestFocusEnabled(false);
        pnlValue.setLayout(new BorderLayout());

        pnlValores.setPreferredSize(new Dimension(154, 30));
        pnlValores.setLayout(new BorderLayout());

        lblInicial.setFont(new Font("Dialog", 0, 11));
        lblInicial.setText("<valor Inicial>");
        lblInicial.setVerticalAlignment(SwingConstants.TOP);
        pnlValores.add(lblInicial, BorderLayout.WEST);

        lblFinal.setFont(new Font("Dialog", 0, 11));
        lblFinal.setText("<valor Final>");
        lblFinal.setVerticalAlignment(SwingConstants.TOP);
        pnlValores.add(lblFinal, BorderLayout.EAST);

        lblFinal1.setFont(new Font("Dialog", 0, 11));
        lblFinal1.setHorizontalAlignment(SwingConstants.CENTER);
        lblFinal1.setText("100%");
        lblFinal1.setVerticalAlignment(SwingConstants.TOP);
        pnlValores.add(lblFinal1, BorderLayout.CENTER);

        pnlValue.add(pnlValores, BorderLayout.CENTER);
        pnlValue.add(pnlDireito, BorderLayout.EAST);
        pnlValue.add(pnlEsquerdo, BorderLayout.WEST);

        jPanel1.add(pnlValue, BorderLayout.SOUTH);

        getContentPane().add(jPanel1, BorderLayout.NORTH);

        pnlEscala.setPreferredSize(new Dimension(85, 70));
        pnlEscala.setLayout(new BorderLayout());

        pnlR.setPreferredSize(new Dimension(35, 35));
        pnlR.setRequestFocusEnabled(false);
        pnlR.setLayout(new FlowLayout(FlowLayout.CENTER, 2, 0));

        btnGrafico.setIcon(new ImageIcon(getClass().getResource("/kpi/imagens/ic_grafico.gif"))); // NOI18N
        ResourceBundle bundle = ResourceBundle.getBundle("international", KpiStaticReferences.getKpiDefaultLocale()); // NOI18N
        btnGrafico.setToolTipText(bundle.getString("KpiPainel_00017")); // NOI18N
        btnGrafico.setBorder(BorderFactory.createEmptyBorder(1, 1, 1, 1));
        btnGrafico.setPreferredSize(new Dimension(25, 25));
        btnGrafico.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent evt) {
                btnGraficoActionPerformed(evt);
            }
        });
        pnlR.add(btnGrafico);

        btnIndicador.setIcon(new ImageIcon(getClass().getResource("/kpi/imagens/ic_planodeacao.gif"))); // NOI18N
        btnIndicador.setToolTipText(bundle.getString("KpiPainel_00010")); // NOI18N
        btnIndicador.setBorder(BorderFactory.createEmptyBorder(1, 1, 1, 1));
        btnIndicador.setPreferredSize(new Dimension(25, 25));
        btnIndicador.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent evt) {
                btnIndicadorActionPerformed(evt);
            }
        });
        pnlR.add(btnIndicador);

        pnlEscala.add(pnlR, BorderLayout.EAST);

        pnlBottom.setPreferredSize(new Dimension(2, 5));
        pnlEscala.add(pnlBottom, BorderLayout.SOUTH);
        pnlEscala.add(pnlL, BorderLayout.WEST);

        pnlTop.setLayout(new FlowLayout(FlowLayout.CENTER, 0, 0));
        pnlEscala.add(pnlTop, BorderLayout.NORTH);

        pnlCenter.setBackground(new Color(204, 204, 204));
        pnlCenter.setPreferredSize(new Dimension(10, 16));
        pnlCenter.setLayout(null);

        lblAnterior.setBackground(new Color(204, 204, 204));
        lblAnterior.setText(bundle.getString("KpiPainel_00013")); // NOI18N
        lblAnterior.setHorizontalTextPosition(SwingConstants.CENTER);
        lblAnterior.setPreferredSize(new Dimension(195, 25));
        pnlCenter.add(lblAnterior);
        lblAnterior.setBounds(0, 20, 180, 20);

        lblValorPrevio.setBackground(new Color(204, 204, 204));
        lblValorPrevio.setHorizontalAlignment(SwingConstants.LEFT);
        lblValorPrevio.setText(bundle.getString("KpiPainel_00015")); // NOI18N
        lblValorPrevio.setPreferredSize(new Dimension(78, 28));
        pnlCenter.add(lblValorPrevio);
        lblValorPrevio.setBounds(0, 40, 180, 20);

        lblAtual.setBackground(new Color(204, 204, 204));
        lblAtual.setFont(new Font("Tahoma", 1, 11)); // NOI18N
        lblAtual.setHorizontalAlignment(SwingConstants.LEFT);
        lblAtual.setText(bundle.getString("KpiPainel_00012")); // NOI18N
        lblAtual.setPreferredSize(new Dimension(61, 28));
        pnlCenter.add(lblAtual);
        lblAtual.setBounds(0, 0, 180, 20);

        pnlEscala.add(pnlCenter, BorderLayout.CENTER);

        getContentPane().add(pnlEscala, BorderLayout.CENTER);

        pack();
    }//GEN-END:initComponents

    private void btnGraficoActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_btnGraficoActionPerformed
        kpi.xml.BIXMLRecord recLinha = getRecordData();
        kpi.swing.graph.KpiGraphIndicador frame = (kpi.swing.graph.KpiGraphIndicador) formController.getForm(
                "GRAPH_IND", recLinha.getString("ENTID"), java.util.ResourceBundle.getBundle("international", kpi.core.KpiStaticReferences.getKpiDefaultLocale()).getString("KpiScoreCarding_00002")).asJInternalFrame();

        //Carregando os dados do gráficos.
        kpi.util.KpiDateUtil date_Util = new kpi.util.KpiDateUtil();
        kpi.core.KpiDateBase dateBase = kpi.core.KpiStaticReferences.getKpiDateBase();
        frame.loadGraphRecord(recLinha.getString("ENTID"),
                date_Util.getCalendarString(dateBase.getDataAcumuladoDe()),
                date_Util.getCalendarString(dateBase.getDataAcumuladoAte()));

    }//GEN-LAST:event_btnGraficoActionPerformed

	private void btnIndicadorActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_btnIndicadorActionPerformed
            try {
                String sText = java.util.ResourceBundle.getBundle("international", kpi.core.KpiStaticReferences.getKpiDefaultLocale()).getString("KpiScoreCarding_00013");
                KpiListaPlanos oFormListaPlanos = (KpiListaPlanos) KpiStaticReferences.getKpiFormController().getForm("LSTPLANOACAO", "0", sText);
                oFormListaPlanos.buildFilter(KpiListaPlanos.FILTER_SCORECARD, record.getString("IDSCOREC"));
            } catch (kpi.core.KpiFormControllerException e) {
                kpi.core.KpiDebug.println(e.getMessage());
            }
	}//GEN-LAST:event_btnIndicadorActionPerformed
    // Variables declaration - do not modify//GEN-BEGIN:variables
    private JButton btnGrafico;
    private JButton btnIndicador;
    private JPanel jPanel1;
    private JPanel jPanel2;
    private JLabel lblAnterior;
    private JLabel lblAtual;
    private JLabel lblDepto;
    private JLabel lblFinal;
    private JLabel lblFinal1;
    private JLabel lblInicial;
    private JLabel lblMeta;
    private JBIHyperlinkLabel lblTitle;
    private JLabel lblValorPrevio;
    private JPanel pLeft;
    private JPanel pRight;
    private JPanel pnlBottom;
    private JPanel pnlCenter;
    private JPanel pnlDireito;
    private JPanel pnlEscala;
    private JPanel pnlEsquerdo;
    private JPanel pnlIndText;
    private JPanel pnlL;
    private JPanel pnlPrevistoAtual;
    private JPanel pnlR;
    private JPanel pnlSlider;
    private JPanel pnlTitle;
    private JPanel pnlTop;
    private JPanel pnlValores;
    private JPanel pnlValue;
    private JBIColorStatusPanel slider;
    // End of variables declaration//GEN-END:variables
}
