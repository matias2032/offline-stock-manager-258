// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get signIn => 'Entrar';

  @override
  String helloUser(String name) {
    return 'Olá, $name';
  }

  @override
  String get welcomeBack => 'Bem-vindo de volta';

  @override
  String get enterPasswordToContinue =>
      'Digite a sua palavra-passe para continuar.';

  @override
  String get password => 'Palavra-passe';

  @override
  String get passwordRequired => 'A palavra-passe é obrigatória';

  @override
  String get createAccount => 'Criar conta';

  @override
  String get welcome => 'Bem-vindo';

  @override
  String get fillDetailsToStart =>
      'Preencha os seus dados para começar a usar a aplicação.';

  @override
  String get nameLabel => 'Nome *';

  @override
  String get nameRequired => 'O nome é obrigatório';

  @override
  String get lastName => 'Apelido';

  @override
  String get phone => 'Telefone';

  @override
  String get email => 'Email';

  @override
  String get invalidEmail => 'Email inválido';

  @override
  String get businessName => 'Nome do negócio';

  @override
  String get currencyLabel => 'Moeda *';

  @override
  String get passwordLabel => 'Palavra-passe *';

  @override
  String get passwordMinLength =>
      'A palavra-passe deve ter pelo menos 6 caracteres';

  @override
  String get confirmPasswordLabel => 'Confirmar palavra-passe *';

  @override
  String get passwordsDoNotMatch => 'As palavras-passe não coincidem';

  @override
  String get failedToCreateAccount => 'Falha ao criar a conta.';

  @override
  String get editProfileTitle => 'Editar perfil';

  @override
  String get updateDetailsBelow => 'Atualize os dados da sua conta abaixo.';

  @override
  String get nameFieldLabel => 'Nome';

  @override
  String get nameRequiredDot => 'O nome é obrigatório.';

  @override
  String get currencyFieldLabel => 'Moeda';

  @override
  String get couldNotUpdateProfile => 'Não foi possível atualizar o perfil.';

  @override
  String get profileUpdatedRelogin =>
      'Perfil atualizado. Inicie sessão novamente.';

  @override
  String get profileUpdated => 'Perfil atualizado.';

  @override
  String get saveChanges => 'Guardar alterações';

  @override
  String get changePasswordTitle => 'Alterar palavra-passe';

  @override
  String get confirmCurrentPasswordPrompt =>
      'Confirme a sua palavra-passe atual para definir uma nova.';

  @override
  String get currentPasswordLabel => 'Palavra-passe atual';

  @override
  String get currentPasswordRequired => 'A palavra-passe atual é obrigatória.';

  @override
  String get newPasswordLabel => 'Nova palavra-passe';

  @override
  String get newPasswordRequired => 'A nova palavra-passe é obrigatória.';

  @override
  String get newPasswordMinLength =>
      'A palavra-passe deve ter pelo menos 6 caracteres.';

  @override
  String get confirmNewPasswordLabel => 'Confirmar nova palavra-passe';

  @override
  String get passwordsDoNotMatchDot => 'As palavras-passe não coincidem.';

  @override
  String get couldNotChangePassword =>
      'Não foi possível alterar a palavra-passe.';

  @override
  String get passwordChangedRelogin =>
      'Palavra-passe alterada. Inicie sessão novamente.';

  @override
  String get passwordChanged => 'Palavra-passe alterada.';

  @override
  String get changePasswordButton => 'Alterar palavra-passe';

  @override
  String get deleteCustomer => 'Eliminar cliente';

  @override
  String confirmDeleteCustomerMessage(String name) {
    return 'Tem a certeza de que deseja eliminar \"$name\"? O histórico de vendas associado será mantido.';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get customersTitle => 'Clientes';

  @override
  String get newCustomer => 'Novo cliente';

  @override
  String get noCustomersYet => 'Ainda não há clientes registados.';

  @override
  String get editCustomer => 'Editar cliente';

  @override
  String get notesLabel => 'Notas';

  @override
  String get createCustomer => 'Criar cliente';

  @override
  String get dashboardTitle => 'Painel';

  @override
  String get hello => 'Olá';

  @override
  String get salesDoingIntro => 'Aqui está o desempenho das suas vendas.';

  @override
  String get finalizedSales => 'Vendas finalizadas';

  @override
  String get totalRevenue => 'Receita total';

  @override
  String get settledCreditSales => 'Vendas a crédito liquidadas';

  @override
  String get dashboardComingSoonTitle => 'Painel a caminho';

  @override
  String get dashboardComingSoonMessage =>
      'Estamos a reconstruir o painel da sua loja para a nova estrutura multi-loja. Volte a verificar em breve.';

  @override
  String get settledCreditRevenueLabel => 'Receita de crédito liquidada';

  @override
  String get dashboardNoStoreSelected =>
      'Selecione uma loja para ver as suas estatísticas.';

  @override
  String saleCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vendas',
      one: '1 venda',
      zero: '0 vendas',
    );
    return '$_temp0';
  }

  @override
  String get suppliersTitle => 'Fornecedores';

  @override
  String get noSuppliersYet => 'Ainda não há fornecedores registados.';

  @override
  String get newSupplier => 'Novo fornecedor';

  @override
  String get editSupplier => 'Editar fornecedor';

  @override
  String get deleteSupplier => 'Eliminar fornecedor';

  @override
  String get createSupplier => 'Criar fornecedor';

  @override
  String get addressLabel => 'Morada';

  @override
  String get deleteSupplierConfirmationGeneric =>
      'Tem a certeza de que deseja eliminar este fornecedor?';

  @override
  String confirmDeleteSupplierMessage(String name) {
    return 'Tem a certeza de que deseja eliminar \"$name\"?';
  }

  @override
  String get descriptionOptionalLabel => 'Descrição (opcional)';

  @override
  String get filterExpensesTitle => 'Filtrar despesas';

  @override
  String get allLabel => 'Todas';

  @override
  String get supplierLabel => 'Fornecedor';

  @override
  String get startDateLabel => 'Data inicial';

  @override
  String get endDateLabel => 'Data final';

  @override
  String get clearLabel => 'Limpar';

  @override
  String get applyLabel => 'Aplicar';

  @override
  String get newExpense => 'Nova despesa';

  @override
  String get editExpense => 'Editar despesa';

  @override
  String get descriptionLabel => 'Descrição';

  @override
  String get descriptionRequired => 'A descrição é obrigatória';

  @override
  String get amountLabel => 'Valor (MZN)';

  @override
  String get amountRequired => 'O valor é obrigatório';

  @override
  String get invalidAmount => 'Valor inválido';

  @override
  String get supplierOptionalLabel => 'Fornecedor (opcional)';

  @override
  String get noneLabel => 'Nenhum';

  @override
  String dateLabel(String date) {
    return 'Data: $date';
  }

  @override
  String get createExpense => 'Criar despesa';

  @override
  String get saveLabel => 'Guardar';

  @override
  String get expensesTitle => 'Despesas';

  @override
  String get deleteExpense => 'Eliminar despesa';

  @override
  String confirmDeleteExpenseMessage(String name) {
    return 'Tem a certeza de que deseja eliminar \"$name\"?';
  }

  @override
  String get deletionReasonLabel => 'Motivo da eliminação';

  @override
  String get noExpensesYet => 'Nenhuma despesa registada.';

  @override
  String get unknownCustomer => 'Cliente desconhecido';

  @override
  String customerNumber(String id) {
    return 'Cliente #$id';
  }

  @override
  String get enterValidPaymentAmount => 'Indique um valor de pagamento válido.';

  @override
  String get paymentExceedsRemainingDebt =>
      'O pagamento excede a dívida restante.';

  @override
  String get paymentRegistered => 'Pagamento registado.';

  @override
  String get couldNotRegisterPayment =>
      'Não foi possível registar o pagamento.';

  @override
  String get cancelSale => 'Cancelar venda';

  @override
  String get cancellationReasonLabel => 'Motivo do cancelamento';

  @override
  String get back => 'Voltar';

  @override
  String get cancelSaleButton => 'Cancelar Venda';

  @override
  String get couldNotCancelSale => 'Não foi possível cancelar a venda.';

  @override
  String get creditSaleTitle => 'Venda a Crédito';

  @override
  String get saleNotFound => 'Venda não encontrada.';

  @override
  String get totalLabel => 'Total';

  @override
  String get paidSoFarLabel => 'Pago até agora';

  @override
  String get remainingDebtLabel => 'Dívida restante';

  @override
  String get statusLabel => 'Estado';

  @override
  String get paymentStatusLabel => 'Estado do pagamento';

  @override
  String get dueDateLabel => 'Data de vencimento';

  @override
  String get registerPayment => 'Registar pagamento';

  @override
  String get amountFieldLabel => 'Valor';

  @override
  String get enterValidAmount => 'Indique um valor válido';

  @override
  String get paymentMethodLabel => 'Método de pagamento';

  @override
  String get cashMethod => 'Dinheiro';

  @override
  String get bankTransferMethod => 'Transferência bancária';

  @override
  String get mpesaMethod => 'M-Pesa';

  @override
  String get emolaMethod => 'E-Mola';

  @override
  String get otherMethod => 'Outro';

  @override
  String get notesOptionalLabel => 'Notas (opcional)';

  @override
  String get paymentHistory => 'Histórico de pagamentos';

  @override
  String get noPaymentsYet => 'Ainda não há pagamentos registados.';

  @override
  String get creditSalesTitle => 'Vendas a Crédito';

  @override
  String get noOutstandingCreditSales => 'Não há vendas a crédito em aberto.';

  @override
  String creditSaleSubtitle(
    String reference,
    String description,
    String owed,
    String currency,
    String paid,
  ) {
    return '$reference — $description\nEm dívida: $owed $currency • Pago até agora: $paid $currency';
  }

  @override
  String get salesGroupLabel => 'Vendas';

  @override
  String get finishedSalesLabel => 'Vendas Concluídas';

  @override
  String get categoriesLabel => 'Categorias';

  @override
  String get financialStatementsLabel => 'Extratos Financeiros';

  @override
  String get logOut => 'Terminar sessão';

  @override
  String get changeThemeLabel => 'Alterar tema';

  @override
  String get confirmLogoutTitle => 'Confirmar saída';

  @override
  String get confirmLogoutMessage =>
      'Tem a certeza de que deseja terminar sessão?';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get statementDetailTitle => 'Detalhe do Extrato';

  @override
  String salesCountLabel(int count) {
    return 'Vendas ($count)';
  }

  @override
  String expensesCountLabel(int count) {
    return 'Despesas ($count)';
  }

  @override
  String get balanceLabel => 'Saldo';

  @override
  String get salesSectionTitle => 'Vendas';

  @override
  String get noSalesInPeriod => 'Sem vendas neste período.';

  @override
  String get expensesSectionTitle => 'Despesas';

  @override
  String get noExpensesInPeriod => 'Sem despesas neste período.';

  @override
  String get generateStatementTitle => 'Gerar Extrato';

  @override
  String get periodLabel => 'Período';

  @override
  String get selectBothDatesMessage =>
      'Selecione a data de início e a data de fim.';

  @override
  String get endDateBeforeStartDateMessage =>
      'A data de fim não pode ser anterior à data de início.';

  @override
  String get selectStartDate => 'Selecionar data de início';

  @override
  String get selectEndDate => 'Selecionar data de fim';

  @override
  String startDatePrefix(String date) {
    return 'Início: $date';
  }

  @override
  String endDatePrefix(String date) {
    return 'Fim: $date';
  }

  @override
  String get generateButtonLabel => 'Gerar';

  @override
  String get financialStatementsTitle => 'Extratos Financeiros';

  @override
  String get noStatementsYet => 'Ainda não foram gerados extratos.';

  @override
  String get deleteStatementTitle => 'Eliminar extrato';

  @override
  String confirmDeleteStatementMessage(String name) {
    return 'Eliminar o extrato $name? Esta ação não pode ser desfeita.';
  }

  @override
  String get couldNotDeleteStatement => 'Não foi possível eliminar o extrato.';

  @override
  String get generateStatementTooltip => 'Gerar extrato';

  @override
  String generatedOnPrefix(String date) {
    return 'Gerado $date';
  }

  @override
  String get nameRequiredMessage => 'O nome é obrigatório';

  @override
  String get createCategoryButton => 'Criar';

  @override
  String get newSaleTitle => 'Nova Venda';

  @override
  String get selectCustomerMessage => 'Selecione um cliente.';

  @override
  String get enterWalkInNameMessage => 'Indique o nome do cliente ocasional.';

  @override
  String get enterValidInitialPaymentMessage =>
      'Indique um valor de entrada válido.';

  @override
  String get initialPaymentExceedsTotalMessage =>
      'A entrada não pode exceder o total da venda.';

  @override
  String get descriptionRequiredMessage => 'A descrição é obrigatória';

  @override
  String get totalAmountLabel => 'Valor total';

  @override
  String get enterValidAmountMessage => 'Indique um valor válido';

  @override
  String get normalLabel => 'Normal';

  @override
  String get creditLabel => 'Crédito';

  @override
  String get useExistingCustomerLabel => 'Usar cliente existente';

  @override
  String get associateExistingCustomerOptionalLabel =>
      'Associar um cliente existente (opcional)';

  @override
  String get customerLabel => 'Cliente';

  @override
  String get walkInCustomerNameLabel => 'Nome do cliente ocasional';

  @override
  String get addDueDateOptionalLabel =>
      'Adicionar data de vencimento (opcional)';

  @override
  String dueDatePrefix(String date) {
    return 'Vence: $date';
  }

  @override
  String get initialPaymentOptionalLabel => 'Entrada (opcional)';

  @override
  String get initialPaymentHelperText =>
      'Deixe em branco se ainda não foi pago nada — o valor total fica em dívida.';

  @override
  String get createSaleButton => 'Criar Venda';

  @override
  String get finishedSalesTitle => 'Vendas Concluídas';

  @override
  String get creditSalesTooltip => 'Vendas a crédito';

  @override
  String get typeLabel => 'Tipo';

  @override
  String get noFinishedSalesYet => 'Ainda não há vendas concluídas.';

  @override
  String get newSaleTooltip => 'Nova venda';

  @override
  String get cancelSaleTitle => 'Cancelar venda';

  @override
  String get backLabel => 'Voltar';

  @override
  String get noCustomerLabel => 'Sem cliente';

  @override
  String customerNumberLabel(int id) {
    return 'Cliente #$id';
  }

  @override
  String get immediateLabel => 'Imediata';

  @override
  String get noInstallmentsRegistered => 'Nenhuma prestação registada.';

  @override
  String paidInInstallmentsMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'prestações',
      one: 'prestação',
      zero: 'prestações',
    );
    return 'Pago em $count $_temp0:';
  }

  @override
  String get splashLoading => 'A preparar a aplicação...';

  @override
  String get switchStoreTooltip => 'Mudar de loja';

  @override
  String get storesTitle => 'Lojas';

  @override
  String get newStore => 'Nova loja';

  @override
  String get storeNameLabel => 'Nome da loja';

  @override
  String get storeNameRequired => 'O nome da loja é obrigatório';

  @override
  String get renameStoreTitle => 'Renomear loja';

  @override
  String get setAsDefault => 'Definir como padrão';

  @override
  String get defaultStoreLabel => 'Padrão';

  @override
  String get deleteStoreTitle => 'Eliminar loja';

  @override
  String confirmDeleteStoreMessage(String name) {
    return 'Tem a certeza de que deseja eliminar \"$name\"?';
  }

  @override
  String get couldNotDeleteStore => 'Não foi possível eliminar a loja.';

  @override
  String get couldNotCreateStore => 'Não foi possível criar a loja.';

  @override
  String get couldNotRenameStore => 'Não foi possível renomear a loja.';

  @override
  String get currentStoreLabel => 'Loja atual';

  @override
  String get allStoresLabel => 'Todas as lojas';

  @override
  String get perStoreBreakdownTitle => 'Resumo por loja';

  @override
  String get consolidatedStatementLabel =>
      'Extracto consolidado (todas as lojas)';

  @override
  String get consolidatedStatementDescription =>
      'Soma os dados de todas as lojas neste período';

  @override
  String get archiveStoreTitle => 'Arquivar loja';

  @override
  String confirmArchiveStoreMessage(Object name) {
    return 'Tem a certeza que quer arquivar \"$name\"? Os dados desta loja (vendas, clientes, extractos) são preservados, mas deixa de aparecer como loja activa.';
  }

  @override
  String get archiveLabel => 'Arquivar';

  @override
  String get couldNotArchiveStore => 'Não foi possível arquivar a loja.';

  @override
  String get backupRestoreTitle => 'Cópia de Segurança';

  @override
  String get backupSectionTitle => 'Criar cópia de segurança';

  @override
  String get backupSectionDescription =>
      'Gera um ficheiro com todos os seus dados e abre o menu de partilha para o guardar num local seguro (nuvem, email, USB...). Como a aplicação é totalmente offline, este ficheiro é a única forma de recuperar dados ou movê-los para outro dispositivo.';

  @override
  String get createBackupButton => 'Criar cópia de segurança';

  @override
  String backupCreatedMessage(String path) {
    return 'Cópia de segurança guardada em: $path';
  }

  @override
  String get backupFailedMessage =>
      'Não foi possível criar a cópia de segurança.';

  @override
  String get restoreSectionTitle => 'Restaurar cópia de segurança';

  @override
  String get restoreSectionDescription =>
      'Escolha um ficheiro de cópia de segurança criado anteriormente. Os dados já existentes neste dispositivo são mantidos — só os registos em falta ou desatualizados são substituídos pelos dados da cópia.';

  @override
  String get restoreBackupButton => 'Escolher ficheiro';

  @override
  String get restoreConfirmTitle => 'Restaurar cópia de segurança?';

  @override
  String get restoreConfirmMessage =>
      'Isto funde a cópia de segurança com os seus dados atuais. Nada é apagado deste dispositivo: para cada registo, mantém-se a versão mais recente — a que já existe aqui ou a que vem da cópia.';

  @override
  String get restoreConfirmButton => 'Continuar';

  @override
  String restoreSuccessMessage(int inserted, int updated, int skipped) {
    return 'Restauro concluído: $inserted novos, $updated atualizados, $skipped sem alteração.';
  }

  @override
  String get saleCreatedMessage => 'Venda criada com sucesso.';

  @override
  String get discardSaleTitle => 'Descartar venda?';

  @override
  String get discardSaleMessage => 'Os dados introduzidos serão perdidos.';

  @override
  String get discardLabel => 'Descartar';

  @override
  String get keepEditingLabel => 'Continuar a editar';

  @override
  String get restoreFailedMessage =>
      'Não foi possível restaurar a cópia de segurança.';

  @override
  String get shareSectionTitle => 'Partilhar cópia de segurança';

  @override
  String get shareSectionDescriptionEmpty =>
      'Crie primeiro uma cópia de segurança para depois poder partilhar exatamente esse ficheiro (email, nuvem, USB...), se quiser uma cópia extra fora deste dispositivo.';

  @override
  String shareSectionDescriptionReady(String fileName) {
    return 'Pronto a partilhar: $fileName';
  }

  @override
  String get shareBackupButton => 'Partilhar cópia de segurança';

  @override
  String get shareFailedMessage => 'Não foi possível abrir o menu de partilha.';

  @override
  String get generatePdfTooltip => 'Gerar PDF';

  @override
  String get referenceColumnLabel => 'Ref.';

  @override
  String get dateColumnLabel => 'Data';

  @override
  String get storeColumnLabel => 'Loja';

  @override
  String get periodToday => 'Hoje';

  @override
  String get periodLast24Hours => '1 dia';

  @override
  String get periodOneWeek => '1 semana';

  @override
  String get periodOneMonth => '1 mês';

  @override
  String get periodThreeMonths => '3 meses';

  @override
  String get periodSixMonths => '6 meses';

  @override
  String get periodOneYear => '1 ano';

  @override
  String get periodCustom => 'Personalizado';

  @override
  String get splashTip1 =>
      'Registe uma venda em segundos, direto do telemóvel.';

  @override
  String get splashTip2 =>
      'Cada venda tem a sua referência. Chega de notas perdidas.';

  @override
  String get splashTip3 =>
      'Dinheiro, M-Pesa, e-Mola ou transferência: escolhe como recebe.';

  @override
  String get splashTip4 => 'Saiba exatamente quanto vendeu hoje.';

  @override
  String get splashTip5 =>
      'Vendeu a crédito? Nunca mais se esqueça de quem lhe deve.';

  @override
  String get splashTip6 => 'Registe cada pagamento e veja a dívida a diminuir.';

  @override
  String get splashTip7 => 'Divida o pagamento em prestações, uma de cada vez.';

  @override
  String get splashTip8 =>
      'Um aviso mostra quantas vendas a crédito ainda estão em aberto.';

  @override
  String get splashTip9 =>
      'Controle cada despesa, da renda à reposição de stock.';

  @override
  String get splashTip10 =>
      'Tenha os seus fornecedores organizados num só lugar.';

  @override
  String get splashTip11 => 'O dinheiro que sai conta tanto como o que entra.';

  @override
  String get splashTip12 =>
      'Filtre despesas por fornecedor ou data e encontre tudo depressa.';

  @override
  String get splashTip13 => 'Gere um extrato financeiro para qualquer período.';

  @override
  String get splashTip14 => 'Vendas menos despesas: o seu saldo, bem claro.';

  @override
  String get splashTip15 =>
      'Transforme o extrato num PDF, pronto a imprimir ou partilhar.';

  @override
  String get splashTip16 =>
      'Os extratos ficam congelados no tempo: os números nunca mudam.';

  @override
  String get splashTip17 => 'Tem várias lojas? Gira todas numa só aplicação.';

  @override
  String get splashTip18 => 'Mude de loja com um só toque.';

  @override
  String get splashTip19 => 'Veja o grupo todo num único extrato consolidado.';

  @override
  String get splashTip20 => 'Compare o contributo de cada loja para o total.';

  @override
  String get splashTip21 =>
      'Conheça os seus clientes e o histórico das suas compras.';

  @override
  String get splashTip22 =>
      'Funciona totalmente offline. Sem internet, sem problema.';

  @override
  String get splashTip23 =>
      'Os seus dados ficam no seu dispositivo, protegidos pela palavra-passe.';

  @override
  String get splashTip24 =>
      'Faça uma cópia de segurança hoje e durma descansado amanhã.';

  @override
  String get welcomeToMiniTitle => 'Bem-vindo ao Mini';

  @override
  String get welcomeSubtitle =>
      'Já tem uma cópia de segurança de outro dispositivo ou de uma instalação anterior?';

  @override
  String get welcomeRestoreButton => 'Restaurar cópia de segurança';

  @override
  String get welcomeCreateNewButton => 'Começar do zero';

  @override
  String get restorePreviewTitle => 'Cópia de segurança encontrada';

  @override
  String restorePreviewSummary(
    String reference,
    String date,
    String userName,
    int storeCount,
    int saleCount,
  ) {
    return 'Referência: $reference\nData: $date\nConta: $userName\nLojas: $storeCount\nVendas: $saleCount';
  }

  @override
  String get restorePreviewConfirmButton => 'Restaurar';

  @override
  String get restoreFreshSuccessMessage =>
      'Cópia restaurada. Inicie sessão com a palavra-passe dessa cópia.';

  @override
  String get backupErrorInvalidFile =>
      'O ficheiro selecionado não é uma cópia de segurança JSON válida.';

  @override
  String get backupErrorUnrecognized =>
      'Este ficheiro não é uma cópia de segurança reconhecida.';

  @override
  String get backupErrorNoUser =>
      'Esta cópia não contém dados da conta, por isso não pode ser restaurada aqui.';

  @override
  String get backupErrorNoStore =>
      'Esta cópia não contém lojas, por isso não pode ser restaurada aqui.';

  @override
  String get backupErrorNewerVersion =>
      'Esta cópia foi criada por uma versão mais recente da aplicação. Atualize a aplicação e tente novamente.';

  @override
  String get backupErrorIntegrity =>
      'Os dados da cópia estão inconsistentes. Nada foi restaurado.';

  @override
  String get activationTitle => 'Ativar o Mini';

  @override
  String get activationSubtitle =>
      'Introduza o código de ativação que recebeu com a compra. É preciso ligação à internet só desta vez.';

  @override
  String get activationCodeLabel => 'Código de ativação';

  @override
  String get activationCodeRequired => 'Introduza o código de ativação';

  @override
  String get activationButton => 'Ativar';

  @override
  String get activationErrorInvalidCode =>
      'Este código não é válido. Verifique e tente novamente.';

  @override
  String get activationErrorAlreadyUsed =>
      'Este código já está em uso noutro dispositivo. Contacte o suporte para mudar a sua licença.';

  @override
  String get activationErrorRevoked =>
      'Esta licença já não está ativa. Contacte o suporte.';

  @override
  String get activationErrorRateLimited =>
      'Demasiadas tentativas. Aguarde alguns minutos e tente novamente.';

  @override
  String get activationErrorNetwork =>
      'Não foi possível contactar o servidor de ativação. Verifique a ligação à internet e tente novamente.';

  @override
  String get activationErrorDevice =>
      'Não foi possível identificar este dispositivo.';

  @override
  String get activationErrorGeneric => 'A ativação falhou. Tente novamente.';

  @override
  String get revenueMixTitle => 'Composição da receita';

  @override
  String get immediateRevenueLabel => 'Receita imediata';

  @override
  String get revenueTrendTitle => 'Evolução da receita';

  @override
  String get peakLabel => 'Pico';

  @override
  String get catalogTitle => 'Catálogo';

  @override
  String get newCatalogItem => 'Novo item';

  @override
  String get editCatalogItem => 'Editar item';

  @override
  String get createCatalogItem => 'Criar item';

  @override
  String get noCatalogItemsYet =>
      'Ainda não há produtos nem serviços registados.';

  @override
  String get deleteCatalogItem => 'Eliminar item';

  @override
  String confirmDeleteCatalogItemMessage(String name) {
    return 'Tem a certeza de que deseja eliminar \"$name\"? As vendas passadas mantêm o histórico.';
  }

  @override
  String get searchLabel => 'Pesquisar';

  @override
  String get productLabel => 'Produto';

  @override
  String get serviceLabel => 'Serviço';

  @override
  String get itemNameLabel => 'Nome';

  @override
  String get itemCodeLabel => 'Código (opcional)';

  @override
  String get categoryLabel => 'Categoria';

  @override
  String get noCategoryLabel => 'Sem categoria';

  @override
  String get unitLabel => 'Unidade';

  @override
  String get salePriceLabel => 'Preço de venda';

  @override
  String get costPriceLabel => 'Preço de custo';

  @override
  String get costPriceHelperText =>
      'Custo de referência. É actualizado automaticamente ao registar uma compra.';

  @override
  String get trackStockLabel => 'Controlar estoque';

  @override
  String get trackStockHelperText =>
      'A quantidade desce a cada venda e sobe a cada compra.';

  @override
  String get minStockLabel => 'Estoque mínimo (alerta)';

  @override
  String get activeLabel => 'Activo';

  @override
  String get inactiveLabel => 'Inactivo';

  @override
  String get newCategory => 'Nova categoria';

  @override
  String get renameCategory => 'Renomear categoria';

  @override
  String get categoryNameLabel => 'Nome da categoria';

  @override
  String get deleteCategory => 'Eliminar categoria';

  @override
  String confirmDeleteCategoryMessage(String name) {
    return 'Eliminar \"$name\"? Os produtos desta categoria são mantidos, apenas ficam sem categoria.';
  }

  @override
  String get noCategoriesYet => 'Ainda não há categorias.';

  @override
  String get stockTitle => 'Estoque';

  @override
  String lowStockFilterLabel(int count) {
    return 'Estoque baixo ($count)';
  }

  @override
  String get belowMinimumLabel => 'Abaixo do mínimo';

  @override
  String stockMinLabel(String min) {
    return 'Mín.: $min';
  }

  @override
  String get noStockItemsYet => 'Ainda não há produtos registados.';

  @override
  String get noInitialStockLabel => 'Sem estoque inicial';

  @override
  String get deletedLabel => 'Eliminado';

  @override
  String get stockHistoryTitle => 'Histórico de estoque';

  @override
  String get noMovementsYet => 'Ainda não há movimentos.';

  @override
  String get stockPurchaseButton => 'Registar compra';

  @override
  String get stockPurchaseTitle => 'Compra de estoque';

  @override
  String get initialStockButton => 'Definir estoque inicial';

  @override
  String get adjustStockButton => 'Ajustar estoque';

  @override
  String get quantityLabel => 'Quantidade';

  @override
  String get unitCostLabel => 'Custo unitário';

  @override
  String get unitCostOptionalLabel => 'Custo unitário (opcional)';

  @override
  String purchaseTotalLabel(String amount) {
    return 'Total: $amount';
  }

  @override
  String get enterValidQuantityMessage => 'Indique uma quantidade válida';

  @override
  String get noteRequiredMessage => 'A nota é obrigatória neste movimento';

  @override
  String get movementTypeLabel => 'Tipo de movimento';

  @override
  String get stockMovementSaved => 'Movimento registado.';

  @override
  String stockPurchaseExpenseDescription(String quantity, String name) {
    return 'Aquisição: $quantity × $name';
  }

  @override
  String get stockPurchaseTag => 'Compra de estoque';

  @override
  String get stockExpenseLockedMessage =>
      'Esta despesa vem de uma compra de estoque e não pode ser editada nem eliminada.';

  @override
  String get movementInitial => 'Estoque inicial';

  @override
  String get movementPurchase => 'Compra';

  @override
  String get movementSale => 'Venda';

  @override
  String get movementSaleReversal => 'Estorno de venda';

  @override
  String get movementAdjustmentIn => 'Ajuste (entrada)';

  @override
  String get movementAdjustmentOut => 'Saída (uso interno/correcção)';

  @override
  String get movementLoss => 'Perda';

  @override
  String get saleItemsTitle => 'Itens';

  @override
  String get addItemButton => 'Adicionar item';

  @override
  String get selectItemTitle => 'Seleccionar item';

  @override
  String get removeItemTooltip => 'Remover item';

  @override
  String get unitPriceLabel => 'Preço unitário';

  @override
  String lineSubtotalLabel(String amount) {
    return 'Subtotal: $amount';
  }

  @override
  String stockAvailableLabel(String quantity, String unit) {
    return 'Em estoque: $quantity $unit';
  }

  @override
  String get outOfStockLabel => 'Esgotado';

  @override
  String get noSellableItemsYet =>
      'Ainda não há produtos ou serviços activos no catálogo.';

  @override
  String get reportsTitle => 'Relatórios';

  @override
  String get lowStockTabLabel => 'Estoque baixo';

  @override
  String get stockValueLabel => 'Valor em estoque';

  @override
  String get marginTabLabel => 'Margem';

  @override
  String get noLowStockItems => 'Nenhum produto abaixo do estoque mínimo.';

  @override
  String get noStockValueYet => 'Ainda não há estoque disponível.';

  @override
  String itemsWithoutCostNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens sem preço de custo, avaliados em 0.',
      one: '1 item sem preço de custo, avaliado em 0.',
    );
    return '$_temp0';
  }

  @override
  String get noCostLabel => 'Sem custo definido';

  @override
  String get marginNoSalesYet => 'Sem vendas com itens neste período.';

  @override
  String get costOfGoodsLabel => 'Custo das mercadorias vendidas';

  @override
  String get marginLabel => 'Margem';

  @override
  String get reportsInfoNote =>
      'Apenas informativo. Estes valores não entram no saldo do extracto, que continua em base de caixa.';

  @override
  String get productsTitle => 'Produtos';

  @override
  String get servicesTitle => 'Serviços';

  @override
  String get productCategoriesTitle => 'Categorias de produtos';

  @override
  String get newProduct => 'Novo produto';

  @override
  String get editProduct => 'Editar produto';

  @override
  String get createProduct => 'Criar produto';

  @override
  String get newService => 'Novo serviço';

  @override
  String get editService => 'Editar serviço';

  @override
  String get createService => 'Criar serviço';

  @override
  String get noProductsYet => 'Ainda não há produtos registados.';

  @override
  String get noServicesYet => 'Ainda não há serviços registados.';

  @override
  String get initialQuantityLabel => 'Quantidade inicial';

  @override
  String get initialQuantityHelperText =>
      'Estoque que já tem. É registado como despesa (quantidade × custo). Para compras posteriores, use \"Movimentar estoque\".';

  @override
  String get serviceUnitHelperText => 'Ex.: hora, serviço';

  @override
  String get moveStockButton => 'Movimentar estoque';

  @override
  String get movementEntryOption => 'Entrada (compra)';

  @override
  String insufficientStockMessage(String quantity, String unit) {
    return 'Só há $quantity $unit em estoque';
  }

  @override
  String get cannotDeleteProductWithStockMessage =>
      'Este produto ainda tem estoque. Registe primeiro uma Saída ou uma Perda (ou desactive o produto).';

  @override
  String get allTypesLabel => 'Todos os tipos';

  @override
  String get allProductsLabel => 'Todos os produtos';

  @override
  String get loadMoreLabel => 'Carregar mais';

  @override
  String get noLowStockProductsMessage => 'Nenhum produto com estoque baixo.';

  @override
  String get saleDetailTitle => 'Detalhe da venda';

  @override
  String get okLabel => 'OK';

  @override
  String get customItemTag => 'Avulso';

  @override
  String outOfStockNotice(String name) {
    return '\"$name\" está esgotado e não pode ser vendido.';
  }

  @override
  String get insufficientStockDialogTitle => 'Estoque insuficiente';

  @override
  String insufficientStockDialogMessage(
    String name,
    String quantity,
    String unit,
  ) {
    return 'Não há estoque suficiente de \"$name\". Só há $quantity $unit em estoque.';
  }

  @override
  String get itemUnavailableTitle => 'Item indisponível';

  @override
  String get itemUnavailableMessage =>
      'Um dos itens deixou de estar disponível (foi desactivado ou eliminado). Está assinalado no carrinho; remova-o para continuar.';

  @override
  String get itemUnavailableLine => 'Este item deixou de estar disponível';

  @override
  String get saleNeedsItemsMessage => 'Adicione pelo menos um item à venda.';

  @override
  String get cartClearedStoreChangedMessage =>
      'A loja mudou, por isso os itens foram removidos da venda.';

  @override
  String get lossesTabLabel => 'Perdas';

  @override
  String get lossesTotalLabel => 'Valor das perdas';

  @override
  String get noLossesInPeriod => 'Sem perdas neste período.';

  @override
  String get customItemsSalesTitle => 'Itens avulsos';

  @override
  String customItemsSalesNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count linhas vendidas',
      one: '1 linha vendida',
    );
    return '$_temp0 sem custo. Não entram na margem acima.';
  }

  @override
  String get initialStockSupplierHelperText =>
      'O estoque inicial já é registado como despesa. Escolha um fornecedor para a associar, ou deixe em branco.';

  @override
  String get pressBackAgainToExit => 'Toque em Voltar novamente para sair';
}
