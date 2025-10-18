{{/*
Expand the name of the chart.
*/}}
{{- define "kubevirt.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "kubevirt.fullname" -}}
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
{{- define "kubevirt.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kubevirt.labels" -}}
helm.sh/chart: {{ include "kubevirt.chart" . }}
{{ include "kubevirt.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kubevirt.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kubevirt.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Operator labels
*/}}
{{- define "kubevirt.operator.labels" -}}
{{ include "kubevirt.labels" . }}
kubevirt.io: virt-operator
{{- end }}

{{/*
Operator selector labels
*/}}
{{- define "kubevirt.operator.selectorLabels" -}}
kubevirt.io: virt-operator
{{- end }}

{{/*
Create the name of the service account to use for the operator
*/}}
{{- define "kubevirt.operator.serviceAccountName" -}}
{{- default "kubevirt-operator" .Values.operator.serviceAccountName }}
{{- end }}

{{/*
Create the namespace
*/}}
{{- define "kubevirt.namespace" -}}
{{- default "kubevirt" .Values.namespace.name }}
{{- end }}

{{/*
Create the operator image
*/}}
{{- define "kubevirt.operator.image" -}}
{{- $registry := .Values.operator.image.registry }}
{{- $repository := .Values.operator.image.repository }}
{{- $tag := .Values.operator.image.tag | default .Chart.AppVersion }}
{{- printf "%s/%s:%s" $registry $repository $tag }}
{{- end }}

{{/*
KubeVirt image registry
*/}}
{{- define "kubevirt.imageRegistry" -}}
{{- if .Values.kubevirt.image.registry }}
{{- .Values.kubevirt.image.registry }}
{{- end }}
{{- end }}

{{/*
KubeVirt image tag
*/}}
{{- define "kubevirt.imageTag" -}}
{{- if .Values.kubevirt.image.tag }}
{{- .Values.kubevirt.image.tag }}
{{- end }}
{{- end }}

{{/*
Priority class name
*/}}
{{- define "kubevirt.priorityClassName" -}}
{{- default "kubevirt-cluster-critical" .Values.priorityClass.name }}
{{- end }}

{{/*
Monitoring namespace
*/}}
{{- define "kubevirt.monitoring.namespace" -}}
{{- default "monitoring" .Values.monitoring.namespace }}
{{- end }}

{{/*
ServiceMonitor namespace
*/}}
{{- define "kubevirt.monitoring.serviceMonitorNamespace" -}}
{{- if .Values.monitoring.serviceMonitorNamespace }}
{{- .Values.monitoring.serviceMonitorNamespace }}
{{- else }}
{{- include "kubevirt.namespace" . }}
{{- end }}
{{- end }}
