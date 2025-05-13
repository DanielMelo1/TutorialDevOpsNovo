# Pipeline de CI/CD com AWS CodePipeline

![AWS CI/CD Pipeline](https://img.shields.io/badge/AWS-CI%2FCD%20Pipeline-orange)
![Node.js](https://img.shields.io/badge/Node.js-14.x-brightgreen)
![Terraform](https://img.shields.io/badge/Terraform-Infrastructure-blueviolet)

Este repositório contém a implementação de um pipeline completo de CI/CD usando AWS CodePipeline, CodeBuild e CodeDeploy para automatizar o deploy de uma aplicação Node.js em uma instância EC2.

## 📋 Visão Geral

O projeto demonstra como implementar um fluxo automatizado que permite fazer alterações no código, enviá-las para o GitHub e ter essas alterações automaticamente compiladas, testadas e implantadas em um ambiente de produção, tudo sem intervenção manual.

## 📖 Artigo Completo

Para uma explicação detalhada e passo a passo de como implementar este pipeline, confira meu artigo no Medium:
[Projeto de Mentoria: Deploy de Aplicação Node.js com AWS CodePipeline, CodeBuild e CodeDeploy](https://medium.com/@dreimao4/projeto-de-mentoria-deploy-de-aplicação-node-js-com-aws-codepipeline-codebuild-e-codedeploy-c7d86054905b)

## 🏗️ Arquitetura

O pipeline integra os seguintes serviços:

- **AWS CodePipeline**: Orquestração do fluxo de CI/CD
- **AWS CodeBuild**: Compilação e construção da aplicação
- **AWS CodeDeploy**: Implantação automatizada na instância EC2
- **GitHub**: Repositório do código fonte
- **Amazon S3**: Armazenamento de artefatos
- **IAM**: Gerenciamento de permissões e acessos

## 🔧 Infraestrutura como Código

A infraestrutura base é gerenciada através do Terraform, incluindo:
- VPC com sub-redes públicas e privadas
- Internet Gateway e tabelas de rotas
- Security Groups
- Instância EC2 (Amazon Linux 2023)
- IAM Roles e políticas

## 📂 Estrutura do Projeto

```
TutorialDevOpsNovo/
├── .vscode/               # Configurações do VS Code
├── scripts/
│   ├── clean_up.sh        # Script de limpeza para o deploy
│   └── start_server.sh    # Script para iniciar o servidor Node.js
├── terraform/             # Código Terraform para infraestrutura
├── app.js                 # Aplicação Node.js principal
├── buildspec.yml          # Configuração do AWS CodeBuild
├── appspec.yml            # Configuração do AWS CodeDeploy
└── README.md              # Documentação do projeto
```

## 📝 Arquivos de Configuração

### appspec.yml
Define como o CodeDeploy deve implantar a aplicação, incluindo:
- Localização dos arquivos
- Scripts a serem executados antes e após a instalação

### buildspec.yml
Define o processo de build no CodeBuild:
- Versão do Node.js
- Comandos para instalação de dependências
- Fases de construção
- Artefatos a serem gerados

## ⚙️ Pré-requisitos

Para reproduzir este projeto, você precisará:

1. Conta AWS com permissões adequadas
2. AWS CLI configurado
3. Terraform instalado
4. Conhecimentos básicos de Node.js
5. Conhecimentos básicos de AWS e CI/CD

## 💡 Principais Benefícios

- **Automatização Total**: Do código ao deploy sem intervenção manual
- **Consistência**: Elimina erros humanos no processo de deploy
- **Feedback Rápido**: Detecção imediata de problemas de build ou deploy
- **Rollback Facilitado**: Possibilidade de reverter rapidamente para versões anteriores
- **Escalabilidade**: Facilidade para adaptar o pipeline a projetos maiores

## 🛠️ Resolução de Problemas Comuns

O projeto inclui soluções para problemas comuns, como:
- Configuração de permissões IAM para o CodeBuild acessar o bucket S3
- Configuração correta dos scripts de deploy
- Diagnóstico de falhas no pipeline

## 👨‍💻 Autor

**Daniel Augusto Reimão Melo**
- GitHub: [DanielMelo1](https://github.com/DanielMelo1)
- LinkedIn: [danielaugustormelo](https://www.linkedin.com/in/danielaugustormelo/)
- Medium: [@dreimao4](https://medium.com/@dreimao4)

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para mais detalhes.
