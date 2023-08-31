# PLSQL-Script_Expurgo_Limpeza_Tabela

Em vários momentos clientes já me pediram ajuda em processos de expurgo, porque o Delete que estavam fazendo só ficava em execução e o ambiente lento, então criei um modelo simples de Expurgo/Limpeza de rápido implementação.

Porque fazer uma limpeza de forma fracionada?
E a resposta é: Como você come um Elefante? Com uma mordida de cada vez.

Quando você tenta realizar um Expurgo/Limpeza de muitos registros de uma única vez o processo via ficar lento e existe uma grande chance de ocorrer um Lock de TM, também vai existir muita concorrência, você vai utilizar uma grande quantidade de UNDO, vai ter um aumento significativo de I/O e com um Expurgo/Limpeza de forma fracionada você evita grande parte desses problemas. 

Segue um modelo simples de Expurgo/Limpeza fracionado que pode ser executado através do SqlDeveloper.

Se para você esse processo deve ser uma rotina, então você pode criar uma procedure e um Job.
