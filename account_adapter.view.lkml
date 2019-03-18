# These views shouldn't be changed, extend them in sf_extends instead.
# If you need to re-generate the file, simply delete it and click "Create View from Table" and rename it from account to _account (for example).

view: account_adapter {
  extension: required #add this if you re-generate this file
  extends: [account_schema]
  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}.id ;;
    hidden: yes
  }

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}._fivetran_synced ;;
    hidden: yes
  }

  dimension: account_number {
    type: string
    sql: ${TABLE}.account_number ;;
  }

  dimension: account_source {
    type: string
    sql: ${TABLE}.account_source ;;
  }

#   dimension: is_active_c {
#     type: string
#     sql: ${TABLE}.active_c ;;
#   }

  dimension: annual_revenue {
    type: number
    sql: ${TABLE}.annual_revenue ;;
    hidden: yes
  }

  dimension: billing_city {
    type: string
    sql: ${TABLE}.billing_city ;;
  }

  dimension: billing_country {
    type: string
    sql: ${TABLE}.billing_country ;;
  }

  dimension: billing_geocode_accuracy {
    type: string
    sql: ${TABLE}.billing_geocode_accuracy ;;
    hidden: yes
  }

  dimension: billing_latitude {
    type: number
    sql: ${TABLE}.billing_latitude ;;
  }

  dimension: billing_longitude {
    type: number
    sql: ${TABLE}.billing_longitude ;;
  }

  dimension: billing_postal_code {
    type: string
    sql: ${TABLE}.billing_postal_code ;;
  }

  dimension: billing_state {
    type: string
    sql: ${TABLE}.billing_state ;;
  }

  dimension: billing_street {
    type: string
    sql: ${TABLE}.billing_street ;;
  }

# not etled by FT
#   dimension: clean_status {
#     type: string
#     sql: ${TABLE}.clean_status ;;
#   }

  dimension: created_by_id {
    type: string
    sql: ${TABLE}.created_by_id ;;
    hidden: yes
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_date ;;
  }

# not ETLd by FT
#   dimension: customer_priority_c {
#     type: string
#     sql: ${TABLE}.customer_priority_c ;;
#   }

#   dimension: dandb_company_id {
#     type: string
#     sql: ${TABLE}.dandb_company_id ;;
#   }
#
#   dimension: description {
#     type: string
#     sql: ${TABLE}.description ;;
#   }
#
#   dimension: duns_number {
#     type: string
#     sql: ${TABLE}.duns_number ;;
#   }

  dimension: domain {
    sql: ${TABLE}.domain_c ;;
  }

  dimension: logo64 {
    sql: ${domain} ;;
    html: <a href="https://na9.salesforce.com/{{ opportunity.id._value }}" target="_new">
      <img src="http://logo.clearbit.com/{{ value }}" height=64 width=64></a>
      ;;
  }

  dimension: logo {
    sql: ${domain} ;;
    html: <a href="http://{{ value }}" target="_new">
      <img src="http://logo.clearbit.com/{{ value }}" height=128 width=128></a>
      ;;
  }

  dimension: fax {
    type: string
    sql: ${TABLE}.fax ;;
    hidden: yes
  }

  dimension: industry {
    type: string
    sql: ${TABLE}.industry ;;
  }

  dimension: is_deleted {
    type: yesno
    sql: ${TABLE}.is_deleted ;;
  }

  dimension: jigsaw {
    type: string
    sql: ${TABLE}.jigsaw ;;
    hidden: yes
  }

  dimension: jigsaw_company_id {
    type: string
    sql: ${TABLE}.jigsaw_company_id ;;
    hidden: yes
  }

  dimension_group: last_activity {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.last_activity_date ;;
  }

  dimension: last_modified_by_id {
    type: string
    sql: ${TABLE}.last_modified_by_id ;;
    hidden: yes
  }

  dimension_group: last_modified {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.last_modified_date ;;
  }

  dimension_group: last_referenced {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.last_referenced_date ;;
    hidden: yes
  }

  dimension_group: last_viewed {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.last_viewed_date ;;
    hidden: yes
  }

  dimension: master_record_id {
    type: string
    sql: ${TABLE}.master_record_id ;;
    hidden: yes
  }

#   dimension: naics_code {
#     type: string
#     sql: ${TABLE}.naics_code ;;
#   }
#
#   dimension: naics_desc {
#     type: string
#     sql: ${TABLE}.naics_desc ;;
#   }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
    html: <a href="https://na9.salesforce.com/{{ account.id._value }}" target="_new">
    <img src="https://www.google.com/s2/favicons?domain=www.salesforce.com" height=16 width=16></a>
    {{ linked_value }};;
  }

# changed from number_of_employees; needs string conversion
  dimension: number_of_employees {
    type: string # changed from number to string since underlying column is string
    sql: ${TABLE}.number_of_employees_c ;;
  }

#   dimension: numberof_locations_c {
#     type: number
#     sql: ${TABLE}.numberof_locations_c ;;
#   }

  dimension: owner_id {
    type: string
    sql: ${TABLE}.owner_id ;;
    hidden: yes
  }

  dimension: ownership {
    type: string
    sql: ${TABLE}.ownership ;;
    hidden: yes
  }

  dimension: parent_id {
    type: string
    sql: ${TABLE}.parent_id ;;
    hidden: yes
  }

  dimension: phone {
    type: string
    sql: ${TABLE}.phone ;;
  }

  dimension: photo_url {
    type: string
    sql: ${TABLE}.photo_url ;;
  }

  dimension: rating {
    type: string
    sql: ${TABLE}.rating ;;
    hidden: yes
  }

  dimension: shipping_city {
    type: string
    sql: ${TABLE}.shipping_city ;;
    hidden: yes
  }

  dimension: shipping_country {
    type: string
    sql: ${TABLE}.shipping_country ;;
    hidden: yes
  }

  dimension: shipping_geocode_accuracy {
    type: string
    sql: ${TABLE}.shipping_geocode_accuracy ;;
    hidden: yes
  }

  dimension: shipping_latitude {
    type: number
    sql: ${TABLE}.shipping_latitude ;;
    hidden: yes
  }

  dimension: shipping_longitude {
    type: number
    sql: ${TABLE}.shipping_longitude ;;
    hidden: yes
  }

  dimension: shipping_postal_code {
    type: string
    sql: ${TABLE}.shipping_postal_code ;;
    hidden: yes
  }

  dimension: shipping_state {
    type: string
    sql: ${TABLE}.shipping_state ;;
    hidden: yes
  }

  dimension: shipping_street {
    type: string
    sql: ${TABLE}.shipping_street ;;
    hidden: yes
  }

  dimension: sic {
    type: string
    sql: ${TABLE}.sic ;;
    hidden: yes
  }

  dimension: sic_desc {
    type: string
    sql: ${TABLE}.sic_desc ;;
    hidden: yes
  }

  dimension: site {
    type: string
    sql: ${TABLE}.site ;;
    hidden: yes
  }

  dimension_group: system_modstamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.system_modstamp ;;
    hidden: yes
  }

  dimension: ticker_symbol {
    type: string
    sql: ${TABLE}.ticker_symbol ;;
    hidden: yes
  }

  dimension: type {
    type: string
    sql: ${TABLE}.type ;;
  }

  dimension: website {
    type: string
    sql: ${TABLE}.website ;;
  }

  measure: count {
    type: count
    drill_fields: [id, name, contact.count, opportunity.count, user.count]
  }
}
