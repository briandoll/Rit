function fillLabel() {
  if (this.value === '') {
    this.style.color = 'gray';
    this.value = this.alt;
  }
  return this;
}

function setTime(container, date, hour) {
  container.children('label').hide();
  container.children('.date').attr('disabled', true);
  container.children('.date').css({'color':'#999'});
  container.children('.date').val(date);
  container.children('.hour').attr('disabled', true);
  container.children('.hour').val(hour);
}

function enableTime(container) {
  container.children('.date').css({'color':'#444'});
  container.children('.date').removeAttr('disabled');
  container.children('.hour').removeAttr('disabled');
}

function setupAllEventSelects() {
  $('div.times select.event').each(function() {
    $(this).trigger('change');
  });
}

function bindDatePickers() {
  $('input[type="text"].date').datepicker({ 'showAnim': 'fadeIn' });
}

function bindInFieldLabels() {
  $('label').inFieldLabels();
}

$(document).ready(function() {
  // show/hide buttons
  $('.toggle').live('click', function() {
    $(this).siblings('.toggleable').toggle();
    return false;
  });

  // fill to clear label
  $('input[type="text"].label-filled')
    .each(fillLabel)
    .bind('focus', function() {
      if (this.value == this.alt) {
        this.value = '';
        this.style.color = 'black';
      }
    })
    .bind('blur', fillLabel);

  // clear labels before submit
  $('form').bind('submit', function() {
    console.log(this);
    $(this).find('input[type="text"].label-filled').each(function() {
      console.log(this);
      if (this.value == this.alt) {
        this.value = '';
      }
    });
    return true;
  });

  // event selects
  $('div.times select.event').live('change', function() {
    var event = all_events[this.value];
    if (!event) {
      enableTime($(this).siblings('.start'));
      enableTime($(this).siblings('.end'));
    }
    else {
      setTime($(this).siblings('.start'), event.start_date, event.start_hour);
      setTime($(this).siblings('.end'), event.end_date, event.end_hour);
    }
    return this;
  });

  bindInFieldLabels();
  bindDatePickers();

});