# Script para criar Excel com gráficos dos custos
# Requer ImportExcel module: Install-Module ImportExcel

Write-Host "📊 Criando Excel com gráficos dos custos..." -ForegroundColor Cyan

# Verificar se o módulo ImportExcel está disponível
if (!(Get-Module -ListAvailable -Name ImportExcel)) {
    Write-Host "⚠️  Módulo ImportExcel não encontrado." -ForegroundColor Yellow
    Write-Host "   Para instalar: Install-Module ImportExcel -Force" -ForegroundColor Yellow
    Write-Host "   Criando Excel básico sem gráficos..." -ForegroundColor Yellow
    
    # Criar Excel básico sem gráficos
    $dados1 = Import-Csv "investimento\dados-custos.csv"
    $dados2 = Import-Csv "investimento\projecao-anual.csv" 
    $dados3 = Import-Csv "investimento\comparacao-ambientes.csv"
    
    $dados1 | Export-Excel "investimento\analise-custos-graficos.xlsx" -WorkSheetName "Detalhes por Recurso" -AutoSize -AutoFilter
    $dados2 | Export-Excel "investimento\analise-custos-graficos.xlsx" -WorkSheetName "Projeção Anual" -AutoSize -AutoFilter
    $dados3 | Export-Excel "investimento\analise-custos-graficos.xlsx" -WorkSheetName "Comparação Ambientes" -AutoSize -AutoFilter
    
    Write-Host "✅ Excel básico criado: investimento\analise-custos-graficos.xlsx" -ForegroundColor Green
} else {
    Write-Host "✅ Módulo ImportExcel encontrado. Criando Excel com gráficos..." -ForegroundColor Green
    
    # Importar dados
    $dadosDetalhes = Import-Csv "investimento\dados-custos.csv"
    $dadosProjecao = Import-Csv "investimento\projecao-anual.csv"
    $dadosComparacao = Import-Csv "investimento\comparacao-ambientes.csv"
    
    # Criar Excel com múltiplas abas e gráficos
    $excelFile = "investimento\analise-custos-graficos.xlsx"
    
    # Aba 1: Detalhes por Recurso
    $dadosDetalhes | Export-Excel $excelFile -WorkSheetName "Detalhes" -AutoSize -AutoFilter -Title "Análise Detalhada por Recurso" -TitleBold -TitleSize 16
    
    # Aba 2: Projeção Anual com gráfico de linha
    $dadosProjecao | Export-Excel $excelFile -WorkSheetName "Projeção Anual" -AutoSize -AutoFilter -Title "Projeção de Custos Anuais" -TitleBold -TitleSize 16 -IncludePivotChart -ChartType LineMarkers -NoLegend
    
    # Aba 3: Comparação Ambientes com gráfico de barras
    $dadosComparacao | Export-Excel $excelFile -WorkSheetName "Comparação" -AutoSize -AutoFilter -Title "Comparação por Ambiente" -TitleBold -TitleSize 16 -IncludePivotChart -ChartType ColumnClustered
    
    # Aba 4: Dashboard Resumo
    $resumo = @(
        [PSCustomObject]@{Metrica="Custo Original (Mensal)"; Valor="R$ 3.026,40"}
        [PSCustomObject]@{Metrica="Custo Otimizado (Mensal)"; Valor="R$ 176,80"}
        [PSCustomObject]@{Metrica="Economia Mensal"; Valor="R$ 2.849,60"}
        [PSCustomObject]@{Metrica="Economia Percentual"; Valor="94,2%"}
        [PSCustomObject]@{Metrica="Economia Anual"; Valor="R$ 34.195,20"}
        [PSCustomObject]@{Metrica="ROI Anual"; Valor="1.617%"}
    )
    
    $resumo | Export-Excel $excelFile -WorkSheetName "Dashboard" -AutoSize -Title "Dashboard Executivo" -TitleBold -TitleSize 18
    
    Write-Host "🎉 Excel com gráficos criado: $excelFile" -ForegroundColor Green
}
