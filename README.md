# Sistema de Agendamento de Consultas

Projeto desenvolvido para um teste técnico de Estagiário Full Stack.

A ideia é simular um sistema simples de agendamento para uma clínica. O usuário escolhe uma data, visualiza os horários disponíveis e pode marcar uma consulta.

O sistema também consulta uma API pública de feriados para impedir agendamentos em finais de semana e feriados nacionais.

## Funcionalidades

- Escolha de uma data para consulta;
- Exibição dos horários disponíveis;
- Criação de novos agendamentos;
- Confirmação do agendamento na tela;
- Bloqueio de horários já ocupados;
- Bloqueio de finais de semana;
- Bloqueio de feriados;
- Validação do horário de funcionamento;
- Persistência dos agendamentos em PostgreSQL;
- Uso do fuso horário de Brasília.

## Regras de negócio

A clínica funciona das **08:00 às 18:00** e cada consulta possui duração de **1 hora**.

Por isso, os horários disponíveis vão de:

```text
08:00 até 17:00
```

Não é possível agendar:

- aos sábados e domingos;
- em feriados;
- fora do horário de funcionamento;
- em um horário que já esteja ocupado.

## Tecnologias utilizadas

- Ruby 3.3.5
- Ruby on Rails 7.1.6
- PostgreSQL
- JavaScript
- HTML / ERB
- CSS
- Minitest

## API de feriados

Para consultar os feriados nacionais de 2026, o projeto utiliza a API pública Nager.Date:

```text
https://date.nager.at/api/v3/PublicHolidays/2026/BR
```

A consulta é feita pelo backend antes de disponibilizar os horários para o usuário.

## Endpoints

### Consultar horários disponíveis

```http
GET /available?date=2026-02-10
```

Exemplo de resposta:

```json
{
  "date": "2026-02-10",
  "timezone": "America/Sao_Paulo",
  "business_day": true,
  "available_slots": [
    "08:00",
    "09:00",
    "10:00",
    "11:00"
  ]
}
```

### Criar um agendamento

```http
POST /appointments
```

Exemplo:

```json
{
  "appointment": {
    "scheduled_at": "2026-02-10T10:00:00-03:00"
  }
}
```

### Listar os agendamentos

```http
GET /appointments
```

## Como rodar o projeto

Clone o repositório:

```bash
git clone https://github.com/caiocastelhano/teste-tecnico-estagiario-garde.git
```

Entre na pasta:

```bash
cd teste-tecnico-estagiario-garde
```

Instale as dependências:

```bash
bundle install
```

Crie o banco de dados:

```bash
bin/rails db:create
```

Execute as migrations:

```bash
bin/rails db:migrate
```

Inicie o servidor:

```bash
bin/rails server
```

Depois, acesse:

```text
http://localhost:3000
```

## Testes

Os testes foram feitos com Minitest.

Para executar:

```bash
bin/rails test
```

Resultado atual:

```text
17 runs
50 assertions
0 failures
0 errors
0 skips
```

Os testes cobrem as principais regras do sistema, como horários disponíveis, feriados, finais de semana, horários duplicados e criação de agendamentos.

## Organização do projeto

A aplicação foi feita em Ruby on Rails.

O backend é responsável por validar os agendamentos, consultar os feriados e salvar os dados no PostgreSQL.

O frontend utiliza JavaScript para consultar os horários disponíveis e enviar os novos agendamentos para o backend.

A integração com a API de feriados foi separada em um `HolidayService`.

## Autor

**Caio Castelhano**

[GitHub](https://github.com/caiocastelhano)  
[Portfólio](https://caiocastelhano.com.br/)