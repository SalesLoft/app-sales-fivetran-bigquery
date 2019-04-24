# These views shouldn't be changed, extend them in sf_extends instead.
# If you need to re-generate the file, simply delete it and click "Create View from Table" and rename it from account to _account (for example).

view: opportunity_adapter {
  extension: required #add this if you re-generate this file
  extends: [opportunity_schema]

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}.id ;;
    hidden: yes
  }

  dimension: type {
    type: string
    sql: ${TABLE}.type ;;
  }

  dimension: account_id {
    type: string
    hidden: yes
    sql: ${TABLE}.account_id ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}.amount ;;
    hidden: yes
  }

  dimension: campaign_id {
    type: string
    hidden: yes
    sql: ${TABLE}.campaign_id ;;
  }

  dimension_group: close {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year,
      fiscal_month_num,
      fiscal_quarter,
      fiscal_quarter_of_year,
      fiscal_year
    ]
    sql: ${TABLE}.close_date ;;
  }

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

  dimension: description {
    type: string
    sql: ${TABLE}.description ;;
  }

  dimension: expected_revenue {
    type: number
    sql: ${TABLE}.expected_revenue ;;
    hidden: yes
  }

  dimension: fiscal {
    type: string
    hidden: yes
    sql: ${TABLE}.fiscal ;;
  }

  dimension: fiscal_quarter {
    type: number
    sql: ${TABLE}.fiscal_quarter ;;
  }

  dimension: fiscal_year {
    type: number
    sql: ${TABLE}.fiscal_year ;;
  }

  dimension: forecast_category {
    type: string
    sql: ${TABLE}.forecast_category ;;
  }

  dimension: forecast_category_name {
    type: string
    sql: ${TABLE}.forecast_category_name ;;
  }

  dimension: has_open_activity {
    type: yesno
    sql: ${TABLE}.has_open_activity ;;
    group_label: "Status"
  }

  dimension: has_opportunity_line_item {
    type: yesno
    sql: ${TABLE}.has_opportunity_line_item ;;
    group_label: "Status"
  }

  dimension: has_overdue_task {
    type: yesno
    sql: ${TABLE}.has_overdue_task ;;
    group_label: "Status"
  }

  dimension: is_closed {
    type: yesno
    sql: ${TABLE}.is_closed ;;
    group_label: "Status"
  }

  dimension: is_deleted {
    type: yesno
    sql: ${TABLE}.is_deleted ;;
    group_label: "Status"
  }

  dimension: is_private {
    type: yesno
    sql: ${TABLE}.is_private ;;
    hidden: yes
  }

  dimension: is_won {
    type: yesno
    sql: ${TABLE}.is_won ;;
    group_label: "Status"
  }

  dimension_group: last_activity {
    type: time
    hidden: yes
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
    hidden: yes
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
    hidden: yes
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
  }

  dimension: lead_source {
    type: string
    sql: ${TABLE}.lead_source ;;
  }


  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
    html:
    <a href="https://{{ salesforce_domain_config._sql }}/{{ opportunity.id._value }}" target="_new">
    <img src="https://www.google.com/s2/favicons?domain=www.salesforce.com" height=16 width=16></a>
    {{ linked_value }};;

  }

  dimension: next_step {
    type: string
    sql: ${TABLE}.next_step ;;
  }

  dimension: order_number_c {
    type: string
    sql: ${TABLE}.order_number_c ;;
  }

  dimension: owner_id {
    type: string
    sql: ${TABLE}.owner_id ;;
    hidden: yes
  }

  dimension: pricebook_2_id {
    type: string
    sql: ${TABLE}.pricebook_2_id ;;
    hidden: yes
  }

  dimension: probability {
    type: number
    sql: ${TABLE}.probability ;;
    hidden: yes
  }

  dimension: source {
    type: string
    sql: 'undefined' ;;
  }

  dimension: stage_name {
    type: string
    sql: ${TABLE}.stage_name ;;
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

  dimension: total_opportunity_quantity {
    type: number
    sql: ${TABLE}.total_opportunity_quantity ;;
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

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      stage_name,
      forecast_category_name,
      name,
      campaign.id,
      campaign.name,
      account.id,
      account.name
    ]
  }



#
#   dimension: main_competitors_c {
#     type: string
#     sql: ${TABLE}.main_competitors_c ;;
#   }
#
#   dimension: tracking_number_c {
#     type: string
#     sql: ${TABLE}.tracking_number_c ;;
#   }
#   dimension: current_generators_c {
#     type: string
#     sql: ${TABLE}.current_generators_c ;;
#   }
#
#   dimension: delivery_installation_status_c {
#     type: string
#     sql: ${TABLE}.delivery_installation_status_c ;;
#   }
}
