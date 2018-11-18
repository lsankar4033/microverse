function lpad(value, padding) {
  var zeroes = new Array(padding+1).join("0");
  return (zeroes + value).slice(-padding);
}

function formatRoundNumber(value) {
  return value < 1000 ? lpad(value, 3) : value
}

export { lpad, formatRoundNumber }
