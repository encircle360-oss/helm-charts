{{/*
Expand the name of the chart.
*/}}
{{- define "roundcube.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "roundcube.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "roundcube.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "roundcube.labels" -}}
helm.sh/chart: {{ include "roundcube.chart" . }}
{{ include "roundcube.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "roundcube.selectorLabels" -}}
app.kubernetes.io/name: {{ include "roundcube.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "roundcube.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "roundcube.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Get the database host
*/}}
{{- define "roundcube.databaseHost" -}}
{{- if eq .Values.database.type "sqlite" -}}
{{- printf "sqlite:////var/roundcube/db/roundcube.db" -}}
{{- else if .Values.database.external.host -}}
{{- .Values.database.external.host -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name .Values.database.type -}}
{{- end -}}
{{- end -}}

{{/*
Get the database secret name
*/}}
{{- define "roundcube.databaseSecretName" -}}
{{- if .Values.database.external.existingSecret -}}
{{- .Values.database.external.existingSecret -}}
{{- else -}}
{{- include "roundcube.fullname" . -}}-db
{{- end -}}
{{- end -}}

{{/*
Get the DES key
*/}}
{{- define "roundcube.desKey" -}}
{{- if .Values.roundcube.desKey -}}
{{- .Values.roundcube.desKey -}}
{{- else -}}
{{- randAlphaNum 24 -}}
{{- end -}}
{{- end -}}