{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "rethinkdb.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "rethinkdb.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Store the namespace
*/}}
{{- define "rethinkdb.namespace" -}}
    {{- .Release.Namespace -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "rethinkdb.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "rethinkdb.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "rethinkdb.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Returns the available value for certain key in an existing secret (if it exists),
otherwise it generates a random value.
*/}}
{{- define "getValueFromSecret" }}
{{- $len := (default 16 .Length) | int -}}
{{- $obj := (lookup "v1" "Secret" .Namespace .Name).data -}}
{{- if $obj }}
{{- index $obj .Key | b64dec -}}
{{- else -}}
{{- randAlphaNum $len -}}
{{- end -}}
{{- end }}

{{/*
Return RethinkDB admin password
*/}}
{{- define "rethinkdb.adminPassword" -}}
{{- if .Values.secretKey }}
    {{- .Values.secretKey -}}
{{- else -}}
    {{- include "getValueFromSecret" (dict "Namespace" (include "rethinkdb.namespace" .) "Name" (include "rethinkdb.secretName" .) "Length" 10 "Key" "rethinkdb-password")  -}}
{{- end -}}
{{- end -}}

{{/*
Get the RethinkDB secret name.
*/}}
{{- define "rethinkdb.secretName" -}}
{{- if .Values.existingSecret }}
    {{- printf "%s" (tpl .Values.existingSecret $) -}}
{{- else -}}
    {{- printf "%s-secret" (include "rethinkdb.fullname" .) -}}
{{- end -}}
{{- end -}}