# Rastreador de Hábitos Sustentáveis

Bem-vindo ao projeto! Este documento contém as instruções básicas para iniciar o ambiente de desenvolvimento e entender alguns conceitos chave da aplicação (como as migrations).

## 🚀 Como Instalar e Rodar o Projeto

1. **Instalar as dependências e preparar o banco de dados:**
   No terminal, na raiz do projeto, execute:
   ```bash
   mix setup
   ```
   *O comando `mix setup` vai baixar as dependências do Elixir (`mix deps.get`), compilar o projeto, criar o banco de dados local (SQLite) e rodar as migrations pendentes (`mix ecto.setup`).*

2. **Rodar o servidor local:**
   Para iniciar a aplicação, execute:
   ```bash
   mix phx.server
   ```
   *A aplicação estará disponível no seu navegador em [`localhost:4000`](http://localhost:4000).*

---

## 🗄️ Como Funcionam as Migrations no Ecto (Phoenix)

As migrations funcionam como um **histórico de controle de versão** do seu banco de dados. Elas garantem que todos os desenvolvedores (e os servidores de produção) tenham exatamente a mesma estrutura de tabelas, sem precisar fazer comandos SQL manuais.

### ⚠️ Regra de Ouro
**Nunca edite uma migration antiga!** 
Se uma migration já foi executada e enviada para o repositório, você não deve editar o arquivo original dela caso queira alterar algo. Como ela já foi executada, o Elixir irá ignorá-la. Em vez disso, você deve criar uma **nova migration** para alterar a tabela existente (usando `alter table`).

### Comandos Básicos de Migration

- **Criar uma nova migration:**
  ```bash
  mix ecto.gen.migration nome_da_migration
  ```
  *(Isso gera um arquivo em `priv/repo/migrations/` com a data atual no nome. Você deve abrir esse arquivo e escrever a estrutura da tabela ou a alteração desejada).*

- **Rodar migrations pendentes:**
  ```bash
  mix ecto.migrate
  ```
  *(Aplica todas as migrations que foram criadas mas que ainda não foram enviadas para o seu banco de dados local).*

- **Desfazer a última migration (Rollback):**
  ```bash
  mix ecto.rollback
  ```
  *(Desfaz a última migration rodada. Isso é muito útil quando você escreve uma migration, roda `mix ecto.migrate`, percebe que esqueceu uma coluna, dá rollback, edita o arquivo atual e roda migrate novamente).*