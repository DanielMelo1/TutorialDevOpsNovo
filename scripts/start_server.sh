#!/bin/bash

# Define a porta em que a aplicação será executada
PORT=80

# Verifica se há algum processo rodando na porta especificada e o finaliza
if lsof -t -i:$PORT > /dev/null; then
    echo "Finalizando processos que estão usando a porta $PORT..."
    kill -9 $(lsof -t -i:$PORT)
else
    echo "Nenhum processo encontrado na porta $PORT."
fi

# Aguarda alguns segundos para garantir que o processo foi encerrado
sleep 2

# Inicia a aplicação e direciona os logs para um arquivo
echo "Iniciando o servidor na porta $PORT..."
nohup node /home/ec2-user/app/app.js > /home/ec2-user/app/app.log 2>&1 &

# Verifica se a aplicação foi iniciada corretamente
if [ $? -eq 0 ]; then
    echo "Servidor iniciado com sucesso. Verifique os logs em /home/ec2-user/app/app.log."
else
    echo "Falha ao iniciar o servidor. Verifique os logs em /home/ec2-user/app/app.log para mais detalhes."
fi
