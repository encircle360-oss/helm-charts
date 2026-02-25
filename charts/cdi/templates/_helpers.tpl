{{/*
Expand the name of the chart.
*/}}
{{- define "cdi.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "cdi.fullname" -}}
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
{{- define "cdi.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cdi.labels" -}}
helm.sh/chart: {{ include "cdi.chart" . }}
{{ include "cdi.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "cdi.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cdi.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Operator labels
*/}}
{{- define "cdi.operator.labels" -}}
{{ include "cdi.labels" . }}
operator.cdi.kubevirt.io: ""
{{- end }}

{{/*
Operator selector labels
*/}}
{{- define "cdi.operator.selectorLabels" -}}
name: cdi-operator
operator.cdi.kubevirt.io: ""
{{- end }}

{{/*
Create the name of the service account to use for the operator
*/}}
{{- define "cdi.operator.serviceAccountName" -}}
{{- default "cdi-operator" .Values.operator.serviceAccountName }}
{{- end }}

{{/*
Create the namespace
*/}}
{{- define "cdi.namespace" -}}
{{- default "cdi" .Values.namespace.name }}
{{- end }}

{{/*
Create the operator image
*/}}
{{- define "cdi.operator.image" -}}
{{- $registry := .Values.operator.image.registry }}
{{- $repository := .Values.operator.image.repository }}
{{- $tag := .Values.operator.image.tag | default .Chart.AppVersion }}
{{- printf "%s/%s:%s" $registry $repository $tag }}
{{- end }}

{{/*
Create a component image reference using the operator's registry and tag
*/}}
{{- define "cdi.componentImage" -}}
{{- $registry := .registry }}
{{- $component := .component }}
{{- $tag := .tag }}
{{- printf "%s/kubevirt/cdi-%s:%s" $registry $component $tag }}
{{- end }}
