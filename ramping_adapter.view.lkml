# Ramping view file will have all ramping related pdts



explore:  first_deal_closed {
  hidden: yes
}
view: first_deal_closed {

  derived_table: {
    explore_source: opportunity {
      filters: {field: opportunity.is_won value: "Yes" }
      column: opportunity_owner_id {field: opportunity_owner.id }
      column: opportunity_owner_name {field: opportunity_owner.name }
      column: hire_date {field: opportunity_owner.created_raw }
      column: first_deal_date {field: opportunity.earliest_close_date}
    }
  }
  dimension: opportunity_owner_id {}
  dimension: hire_date {}
  dimension: first_deal_date {}
  dimension_group: _to_first_deal {
    type: duration
    sql_start: ${hire_date}  ;;
    sql_end: ${first_deal_date} ;;
  }
}

# view: first_meeting {
#   derived_table: {
#     explore_source: opportunity {
#       filters: {field: task.is_meeting value: "Yes"}
#       column: opportunity_id {field:opportunity.id}
#       column: meeting_date {field:task.activity_raw}
#       derived_column: first_meeting {
#         sql: FIRST_VALUE (meeting_date) OVER (PARTITION BY opportunity_id order by meeting_date rows between unbounded preceding and unbounded following)  ;;
#       }}}
#   dimension: first_meeting {type: date_raw hidden:yes}
#   dimension: opportunity_id {primary_key: yes}
# }
