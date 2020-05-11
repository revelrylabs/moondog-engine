{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "moondog.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "moondog.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "moondog.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "moondog.labels" -}}
app.kubernetes.io/name: {{ include "moondog.name" . }}
helm.sh/chart: {{ include "moondog.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
If input is given, check that it's 32 bytes in length
If no input is given, generate 32 random bytes
*/}}
{{- define "moondog.random32" -}}
{{- $value := default (randAlphaNum 32) . }}
{{- $length := len $value }}
{{- if eq $length 32 -}}
{{ $value }}
{{- else -}}
{{- fail "Value must be exactly 32 bytes" -}}
{{- end -}}
{{- end -}}

{{/*
If input is given, check that it's 16 bytes in length
If no input is given, generate 16 random bytes
*/}}
{{- define "moondog.random16" -}}
{{- $value := default (randAlphaNum 16) . }}
{{- $length := len $value }}
{{- if eq $length 16 -}}
{{ $value }}
{{- else -}}
{{- fail "Value must be exactly 16 bytes" -}}
{{- end -}}
{{- end -}}
