# API Reference — {Nome da Feature}

> **Versão:** v{major}.{minor}.{patch}
> **Data:** {YYYY-MM-DD}
> **Módulo:** `src/modules/{module-name}/`
> **Destinatário:** Time de Frontend (Wash) e Mobile (River)

---

## Endpoints

---

### POST `/api/v1/{resource}`

**Descrição:** _(o que este endpoint faz)_

**Auth:** `Bearer <JWT>`

**Headers:**

| Header | Obrigatório | Descrição |
|--------|-------------|-----------|
| `Authorization` | Sim | `Bearer <access_token>` |
| `x-user-timezone` | _(Sim/Não)_ | Timezone do usuário, ex: `America/Sao_Paulo` |

**Path Params:** _(remover se não houver)_

| Param | Tipo | Descrição |
|-------|------|-----------|
| `:id` | `string (UUID)` | ID do recurso pai |

**Request Body:**

```json
{
  "field1": "string",        // * obrigatório
  "field2": 123,             // * obrigatório
  "optionalField": "string"  // opcional
}
```

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| `field1` | `string` | Sim | _(descrição)_ |
| `field2` | `number` | Sim | _(descrição)_ |
| `optionalField` | `string` | Não | _(descrição)_ |

**Response — 201 Created:**

```json
{
  "id": "uuid",
  "field1": "string",
  "field2": 123,
  "createdAt": "2026-05-11T12:00:00.000Z"
}
```

**Respostas de Erro:**

| Status | Código | Causa |
|--------|--------|-------|
| `400` | `BadRequestException` | Campos obrigatórios ausentes ou inválidos |
| `401` | `UnauthorizedException` | Token ausente ou expirado |
| `403` | `ForbiddenException` | Sem permissão para este recurso |
| `404` | `NotFoundException` | Recurso pai não encontrado |

**Exemplo cURL:**

```bash
curl -X POST https://api.myproject.com.br/api/v1/{resource} \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "field1": "valor",
    "field2": 123
  }'
```

---

### GET `/api/v1/{resource}`

**Descrição:** _(o que este endpoint faz)_

**Auth:** `Bearer <JWT>`

**Query Params:**

| Param | Tipo | Obrigatório | Padrão | Descrição |
|-------|------|-------------|--------|-----------|
| `page` | `number` | Não | `1` | Página atual |
| `offset` | `number` | Não | `20` | Itens por página |
| `status` | `string` | Não | — | Filtro de status |

**Response — 200 OK:**

```json
{
  "total": 42,
  "items": [
    {
      "id": "uuid",
      "field1": "string",
      "createdAt": "2026-05-11T12:00:00.000Z"
    }
  ],
  "page": 1,
  "offset": 20
}
```

**Respostas de Erro:**

| Status | Código | Causa |
|--------|--------|-------|
| `401` | `UnauthorizedException` | Token ausente ou expirado |
| `403` | `ForbiddenException` | Sem permissão |

**Exemplo cURL:**

```bash
curl -X GET "https://api.myproject.com.br/api/v1/{resource}?page=1&offset=20" \
  -H "Authorization: Bearer <token>"
```

---

## Notas de Integração

> Informações adicionais que o frontend/mobile deve saber para integrar corretamente.

- _(ex: O campo `createdAt` é sempre UTC — converter no cliente para o timezone do usuário)_
- _(ex: O endpoint de listagem suporta paginação padrão `IPagination<T>` — usar `total` para calcular páginas)_
- _(ex: Em caso de `403`, redirecionar para tela de permissão negada)_
