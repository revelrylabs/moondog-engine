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
32 bytes of user-supplied or random characters, base64 encoded
*/}}
{{- define "moondog.bytes32" -}}
{{- $param := (dict "length" 32 "input" .input) -}}
{{- (include "moondog.randomPadded" $param) | b64enc | quote -}}
{{- end -}}

{{/*
Get a string of a certain length
truncated and/or padded with random chars if necessary
*/}}
{{- define "moondog.randomPadded" -}}
{{- $length := .length }}
{{- $input := default "" .input }}
{{- $padding := randAlphaNum $length }}
{{- printf "%s%s" $input $padding | trunc $length -}}
{{- end -}}
