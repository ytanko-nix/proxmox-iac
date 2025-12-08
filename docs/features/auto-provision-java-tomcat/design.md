# Feature Design: Auto Provision Java + Tomcat

## Metadata
- Author: Agent
- Created: 2025-12-08
- Status: Draft
- Related issues/PRs: N/A

## Goals and Motivation
Problem: После создания VM через Terraform необходимо автоматически установить Java и Tomcat, дождаться готовности машины и вывести пользователю подтверждающее сообщение с информацией о машине.

Proposed Solution: Использовать Terraform provisioners для:
1. Ожидания готовности VM (SSH доступность)
2. Запуска Ansible playbook для установки Java 17 + Tomcat 10.1
3. Верификации успешной установки
4. Вывода сообщения с именем VM и IP-адресом

Benefits:
- Полностью автоматизированный процесс развертывания
- Верификация успешности установки
- Информативный вывод для пользователя

## Requirements

### Functional Requirements
- FR-1: После создания VM автоматически дождаться её готовности (SSH доступность)
- FR-2: Установить Python3 (зависимость для Ansible)
- FR-3: Запустить Ansible playbook для установки Java 17 и Tomcat 10.1
- FR-4: Верифицировать наличие Java на машине
- FR-5: Верифицировать наличие Tomcat на машине
- FR-6: Вывести сообщение: "Java и Tomcat установлены на машину [имя] с адресом [IP]"

### Non-Functional Requirements
- Performance: Установка должна завершиться в течение 10 минут
- Security: SSH ключи не должны попадать в логи
- Reliability: При ошибке установки — чёткое сообщение об ошибке
- Maintainability: Версии Java/Tomcat должны быть конфигурируемыми

## Assumptions and Constraints

Assumptions:
- VM template имеет Cloud-Init и поддерживает SSH
- Сеть настроена (DHCP или статический IP)
- SSH private key доступен локально

Constraints:
- Terraform provisioners выполняются только при создании ресурса
- Ansible требует Python на целевой машине

Out of Scope:
- Конфигурация приложений внутри Tomcat
- SSL/TLS настройка для Tomcat

## Architecture and Design

### Components

Component 1: Terraform Provisioners
- Purpose: Оркестрация post-deployment автоматизации
- Responsibilities: Ожидание VM, запуск Ansible
- Interactions: SSH к VM, вызов ansible-playbook

Component 2: Ansible Playbook (java_tomcat.yml)
- Purpose: Установка и конфигурация Java + Tomcat
- Responsibilities: Установка пакетов, настройка systemd, firewall
- Interactions: SSH к VM, dnf/apt

Component 3: Verification & Output
- Purpose: Проверка успешности и информирование пользователя
- Responsibilities: Проверка java -version, curl Tomcat, вывод сообщения
- Interactions: SSH к VM, stdout

### Dependencies

| Dependency | Version | Usage Spec | Purpose |
|------------|--------:|-----------:|---------|
| Terraform CLI | ≥ 1.3.0 | — | Infrastructure provisioning |
| bpg/proxmox | ~> 0.87.0 | — | Proxmox provider |
| Ansible Core | 2.19.1 | `.tessl/usage-specs/tessl/pypi-ansible-core/` | Post-configuration |

### Flow Diagram

```
Terraform Apply
    ↓
proxmox_virtual_environment_vm created
    ↓
remote-exec provisioner:
    - Wait for SSH
    - Install Python3
    ↓
local-exec provisioner:
    - Run ansible-playbook java_tomcat.yml
        ↓
    Ansible tasks:
        - Install Java 17
        - Install Tomcat 10.1
        - Configure systemd
        - Health check (curl localhost:8080)
        ↓
    Verification:
        - java -version
        - systemctl status tomcat
        ↓
    Output message:
        "Java и Tomcat установлены на [name] ([IP])"
```

## Implementation Stages

### Stage 1: Verify and Fix Current Implementation
Description: Проверить работоспособность текущих provisioners

Tasks:
- Проверить синтаксис provisioners в main.tf
- Проверить корректность путей и переменных
- Убедиться, что ipv4_addresses доступен корректно

Exit Criteria:
- [ ] terraform validate проходит успешно
- [ ] Provisioners используют правильные атрибуты ресурса

### Stage 2: Add Verification and Output
Description: Добавить верификацию установки и вывод сообщения

Tasks:
- Добавить верификацию java -version после Ansible
- Добавить верификацию Tomcat (curl или systemctl)
- Добавить финальный вывод с именем VM и IP

Exit Criteria:
- [ ] Java верифицирован на целевой машине
- [ ] Tomcat верифицирован на целевой машине
- [ ] Выводится сообщение с именем и IP

### Stage 3: Documentation
Description: Обновить документацию

Tasks:
- Обновить .tessl/project/spec.md
- Создать todo.md для фичи
- Обновить README если нужно

Exit Criteria:
- [ ] Документация актуальна
- [ ] Фича задокументирована в spec.md

## Acceptance Criteria
- [ ] AC-1: VM создаётся через terraform apply
- [ ] AC-2: Java 17 автоматически устанавливается
- [ ] AC-3: Tomcat 10.1 автоматически устанавливается
- [ ] AC-4: Установка верифицируется (java -version, Tomcat health)
- [ ] AC-5: Выводится сообщение "Java и Tomcat установлены на [name] с адресом [IP]"

## Testing

Test Scenario 1: Full Deployment
- Preconditions: Template существует, SSH ключи настроены
- Steps:
  1. terraform apply
  2. Дождаться завершения
- Expected: VM создана, Java+Tomcat установлены, сообщение выведено

Verification Commands:
```bash
# На VM
java -version
systemctl status tomcat
curl http://localhost:8080

# Локально
terraform output vm_ip
terraform output vm_name
```

## References
- Project Spec: `.tessl/project/spec.md`
- Ansible Playbook: `ansible/java_tomcat.yml`
- Terraform Main: `terraform/main.tf`
